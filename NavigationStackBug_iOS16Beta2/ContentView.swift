//
//  ContentView.swift
//  NavigationStackBug_iOS16Beta2
//
//  Created by Jason Ji on 6/28/22.
//

import Combine
import SwiftUI

/// Overview:
/// Two types of data objects: Plans and Entries. A Plan may contain multiple Entries.
/// Three levels of screens: All Plans View, Plan Details View, Entry Details View. Each one is a drill-down detail view of the previous.

/// Problem: if initializing the navigation stack on Plan 1 Details view, and then drill into Entry 1 Details view,
/// I expect the navigation stack to be All Plans view > Plan Details view > Entry Details view.
/// Instead, the navigation stack is All Plans view > Entry Details 1 view > Entry Details 1 view.
/// In other words, Entry Details 1 view is duplicated in the stack, while Plan Details 1 view is gone.
/// Once you pop all the way back to root (All Plans view), then navigation starts to behave as expected again.

// MARK: - Data Models -
struct Plan: Identifiable {
    let id: String
    let name: String
    let entries: [Entry]
}

struct Entry: Identifiable {
    let id: String
    let name: String
}

// MARK: - Navigation -

public enum Screen: Hashable {
    case allPlans, planDetail(planId: String), entryDetail(entryId: String)
}

public class Coordinator: ObservableObject {
    @Published public var navigationStack: [Screen]
    let store = Store()
    
    public init(screens: [Screen] = []) {
        self._navigationStack = Published(initialValue: screens)
    }
    
    @ViewBuilder
    public func makeDestination(for screen: Screen) -> some View {
        switch screen {
        case .planDetail(let planId):
            PlanDetailsView(plan: store.fetchPlan(id: planId))
        case .entryDetail(let entryId):
            EntryDetailsView(entry: store.fetchEntry(id: entryId))
        default:
            let _ = assertionFailure("destination not implemented")
            EmptyView()
        }
    }
}

class Store {
    let plans: [Plan]
    
    init() {
        plans = [
            Plan(id: "0", name: "Plan 0", entries: [
                Entry(id: "1", name: "Entry 1"),
                Entry(id: "2", name: "Entry 2")
            ])
        ]
    }
    
    func fetchPlan(id: String) -> Plan {
        return self.plans.filter({ $0.id == id }).first!
    }
    
    func fetchEntry(id: String) -> Entry {
        return self.plans.flatMap(\.entries).filter({ $0.id == id }).first!
    }
}

// MARK: - Views -

struct RootView: View {
    // If you start with `var coordinator = Coordinator()`,
    // then of course we start at the root, but otherwise the navigation stack behaves as expected.
    @StateObject var coordinator = Coordinator(screens: [.planDetail(planId: "0")])
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationStack) {
            AllPlansView(plans: coordinator.store.plans)
                .navigationDestination(for: Screen.self) { screen in
                    coordinator.makeDestination(for: screen)
                }
        }
    }
}

class AllPlansViewModel: ObservableObject {
    let plans: [Plan]
    
    init(plans: [Plan]) {
        self.plans = plans
    }
}

struct AllPlansView: View {
    @StateObject var viewModel: AllPlansViewModel
    
    init(plans: [Plan]) {
        self._viewModel = StateObject(wrappedValue: AllPlansViewModel(plans: plans))
    }
    
    var body: some View {
        List(viewModel.plans) { plan in
            NavigationLink(value: Screen.planDetail(planId: plan.id)) {
                Text(plan.name)
            }
        }
        .navigationTitle("All Plans View")
    }
}

class PlanDetailsViewModel: ObservableObject {
    @Published var plan: Plan
    
    init(plan: Plan) {
        self.plan = plan
    }
}

struct PlanDetailsView: View {
    @StateObject var viewModel: PlanDetailsViewModel
    
    init(plan: Plan) {
        _viewModel = StateObject(wrappedValue: PlanDetailsViewModel(plan: plan))
    }
    
    var body: some View {
        List(viewModel.plan.entries) { entry in
            NavigationLink(value: Screen.entryDetail(entryId: entry.id)) {
                Text(entry.name)
            }
        }
        .navigationTitle("Plan Details")
    }
}

class EntryDetailsViewModel: ObservableObject {
    @Published var entry: Entry
    
    init(entry: Entry) {
        self.entry = entry
    }
}

struct EntryDetailsView: View {
    @StateObject var viewModel: EntryDetailsViewModel
    
    init(entry: Entry) {
        _viewModel = StateObject(wrappedValue: EntryDetailsViewModel(entry: entry))
    }
    
    var body: some View {
        Text(viewModel.entry.name)
            .navigationTitle("Entry Details")
    }
}
