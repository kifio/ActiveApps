//
//  ObserveRunningAppsUseCase.swift
//  ActiveApps
//
//  Created by imurashov on 11.02.2026.
//

import Combine

protocol ObserveRunningAppsUseCase {
    func execute() -> AnyPublisher<[ApplicationRecord], Never>
}

final class ObserveRunningAppsUseCaseImplementation: ObserveRunningAppsUseCase {
    private let repository: RunningAppRepository
    
    init(repository: RunningAppRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[ApplicationRecord], Never> {
        return repository.observeRunningApps()
    }
}
