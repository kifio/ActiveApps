//
//  ViewController.swift
//  ActiveApps
//
//  Created by imurashov on 11.02.2026.
//

import Cocoa
import Combine

class ViewController: NSViewController {
    
    @IBOutlet weak var activeTasksView: NSTableView!
    
    private let viewModel: ViewModel = ViewModelImplementation()
    private let tapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = [AnyCancellable]()
    // TODO: DiffableDataSource instead of list in ViewController
    private var runningApplications = [ApplicationRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activeTasksView.delegate = self
        activeTasksView.dataSource = self
        
        let output = viewModel.configure(
            Input(saveDataPublisher: tapSubject.eraseToAnyPublisher())
        )
        
        output.runningApplicationsPublisher
            .sink(receiveValue: { runningApplications in
                self.runningApplications = runningApplications
                self.activeTasksView.reloadData()
            })
            .store(in: &cancellables)
    }
}



extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        runningApplications.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier("ApplicationCell"),
            owner: self
        ) as? NSTableCellView
        let pid = runningApplications[row].pid
        let name = runningApplications[row].name
        cellView?.textField?.stringValue = "\(pid): \(name)"
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
    
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        
    }
}
