//
//  Presenter.swift
//  ActiveApps
//
//  Created by imurashov on 11.02.2026.
//

import Combine

struct Input {
    let saveDataPublisher: AnyPublisher<Void, Never>
}

struct Output {
    let runningApplicationsPublisher: AnyPublisher<[ApplicationRecord], Never>
}

protocol ViewModel {
    func configure(_ input: Input) -> Output
}

final class ViewModelImplementation: ViewModel {

    private var cancellables = [AnyCancellable]()
    // TODO: UseCase for observing data instead of repository in ViewModel
    private let repository: RunningAppRepository = RunningAppRepositoryImplementation()
    
    func configure(_ input: Input) -> Output {
        input.saveDataPublisher
            .sink(receiveValue: {
                // TODO: save to database
            })
            .store(in: &cancellables)
        
        return Output(
            runningApplicationsPublisher: repository.observeRunningApps()
        )
    }
}
