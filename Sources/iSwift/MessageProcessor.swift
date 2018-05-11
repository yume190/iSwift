//
//  MessageProcessor.swift
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

import Foundation
import Dispatch
import SourceKit
import SourceKittenFramework
import FileKit
import Basic

class MessageProcessor {
    static var executionCount: Int {
        _executionCount += 1
        return _executionCount
    }
    
    static var _executionCount: Int = 0
    
    static var session: String = ""

    fileprivate static let projectDirectoryPath = AbsolutePath(FileKit.projectFolder)
    fileprivate static let replArgs: [String] = [
        "-I", projectDirectoryPath.appending(components: ".build","release").asString,
        "-L", projectDirectoryPath.appending(components: ".build","release").asString,
        "-lISwiftDependency",
    ]
    fileprivate static let replWrapper = try! REPLWrapper(command: "/usr/bin/swift", arguments: replArgs, prompt: "^\\s*\\d+>\\s*$", continuePrompt: "^\\s*\\d+\\.\\s*$")
    
    static func run(_ inMessageQueue: BlockingQueue<Message>, outMessageQueue: BlockingQueue<Message>) {
        while true {
            let message = inMessageQueue.take()
            let requestHeader = message.header
            
            Logger.debug.print("Processing new message...\(message.header.msgType)")
            
            guard let replyType = requestHeader.msgType.replyType else { continue }
            
            let replyHeader = Header(session: requestHeader.session, msgType: replyType)
            
            let replyContent: Contentable
            switch replyType {
            case .KernelInfoReply:
                replyContent = KernelInfoReply()
            case .HistoryReply:
                replyContent = HistoryReply(history: [])
            case .ExecuteReply:
                let _currentExecutionCount = executionCount
                replyContent = ExecuteReply(status: .Ok, executionCount: _currentExecutionCount, userExpressions: nil)
                if let executeRequest = message.content as? ExecuteRequest {
                    execute(message, cmd: executeRequest.code, executionCount: _currentExecutionCount, parentHeader: requestHeader, metadata: [:])
                }
            case .IsCompleteReply:
                let content = message.content as! IsCompleteRequest
                replyContent = IsCompleteReply(status: content.code.isCompletedCode() ? "complete" : "incomplete", indent: nil)
            case .ShutdownReply:
                let content = message.content as! ShutdownRequest
                
                Logger.info.print("Shutting down...")
                
                do {
                    try replWrapper.shutdown(content.restart)
                } catch let e {
                    Logger.critical.print(e)
                }
                
                replyContent = ShutdownReply(restart: content.restart)
            case .CompleteReply:
                let content = message.content as! CompleteRequest
                
                let path = "\(UUID().uuidString).swift"
                let r = Request.codeCompletionRequest(file: path, contents: content.code, offset: Int64(content.cursorPosition), arguments: ["-c", path, "-sdk", sdkPath()])
                
                Logger.debug.print("Sending sourcekitten request -- \(r)")
                
                let completionItems = CodeCompletionItem.parse(response: try! r.send())
                let matches = completionItems.compactMap { $0.descriptionKey }
                let cursorEnd = content.cursorPosition
                let cursorStartOffset = completionItems.first?.numBytesToErase ?? 0
                
                replyContent = CompleteReply(matches: matches, cursorStart: cursorEnd - Int(cursorStartOffset), cursorEnd: cursorEnd, status: "ok")
            default:
                continue
            }
            
            let replyMessage = Message(idents: message.idents, header: replyHeader, parentHeader: requestHeader, metadata: [:], content: replyContent, extraBlobs: [])
            
            outMessageQueue.add(replyMessage)
        }
    }
    
    private static var IOPubMessageSerialQueue = DispatchQueue(label: "iSwiftCore.MessageProcessor.IOPubMessage")
    
    fileprivate static func execute(_ origin: Message, cmd: String, executionCount: Int, parentHeader: Header, metadata: [String: Any]) {
        if session.isEmpty {
            session = parentHeader.session
            
            // Sending starting status.
            sendIOPubMessage(origin, type: .Status, content: Status(executionState: "starting"), parentHeader: nil)
        }
        
        sendIOPubMessage(origin, type: .Status, content: Status(executionState: "busy"), parentHeader: parentHeader)
        
        let result = replWrapper.runCommand(cmd).trim()
        let content = ExecuteResult(executionCount: executionCount, data: ["text/plain": result], metadata: [:])
        
        sendIOPubMessage(origin, type: .Status, content: Status(executionState: "idle"), parentHeader: parentHeader)
        
        sendIOPubMessage(origin, type: .ExecuteResult, content: content, parentHeader: parentHeader)
    }
    
    fileprivate static func sendIOPubMessage(_ origin: Message, type: MessageType, content: Contentable, parentHeader: Header?, metadata: [String: Any] = [:]) {
        IOPubMessageSerialQueue.async { () -> Void in
            let header = Header(session: session, msgType: type)
            let message = Message(idents: origin.idents, header: header, parentHeader: parentHeader, metadata: metadata, content: content, extraBlobs: [])
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "IOPubNotification"), object: message, userInfo: nil)
        }
    }
}
