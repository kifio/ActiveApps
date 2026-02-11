//
//  RunningAppRepository.swift
//  ActiveApps
//
//  Created by imurashov on 11.02.2026.
//

import Cocoa
import Combine

protocol RunningAppRepository {
    func observeRunningApps() ->  AnyPublisher<[ApplicationRecord], Never>
}

final class RunningAppRepositoryImplementation: RunningAppRepository {
    
    func observeRunningApps() -> AnyPublisher<[ApplicationRecord], Never> {
        let  runningAppsSubject = CurrentValueSubject<[ApplicationRecord], Never>(
            NSWorkspace.shared.runningApplications.map { ApplicationRecord($0) }
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            var currentValue = runningAppsSubject.value
            
            if
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                !currentValue.contains(where: {
                    $0.bundleID == app.bundleURL?.absoluteString
                })
            {
                currentValue.append(ApplicationRecord.init(app))
                runningAppsSubject.send(currentValue)
            }
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            if
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            {
                var currentValue = runningAppsSubject.value
                currentValue.removeAll(where: {
                    $0.name == app.localizedName && $0.bundleID == app.bundleURL?.absoluteString
                })
                runningAppsSubject.send(currentValue)
            }
        }
        
        return runningAppsSubject.eraseToAnyPublisher()
    }
}

fileprivate extension ApplicationRecord {
    init(_ application: NSRunningApplication) {
        self.init(
            name: application.localizedName ?? "localized name",
            bundleID: application.bundleURL?.absoluteString ?? "bundle url",
            pid: application.processIdentifier as Int32
        )
    }
}
