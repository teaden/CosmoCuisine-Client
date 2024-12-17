//
//  ResultsViewController.swift
//  CosmoCuisine-Client
//
//  Created by Tyler Eaden on 12/17/24.
//

import UIKit

class ResultsViewController: UIViewController {
    private let repository: CoreDataRepository
    private let ocrResults: [String]
    private var products: [ProductEntity] = []

    // UI elements
    private var loadingIndicator: UIActivityIndicatorView?
    private var loadingLabel: UILabel?
    private var noResultsLabel: UILabel?
    private var pageViewController: UIPageViewController?
    private var pageControl: UIPageControl?

    init(repository: CoreDataRepository, ocrResults: [String]) {
        self.repository = repository
        self.ocrResults = ocrResults
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        showLoadingView()

        DispatchQueue.global(qos: .userInitiated).async {
            let matchedRecords = try? self.repository.fetchLevDistBrandsJP(for: self.ocrResults)
            DispatchQueue.main.async {
                self.hideLoadingView()
                if let records = matchedRecords, !records.isEmpty {
                    self.products = records
                    self.updateUIWithRecords(records)
                } else {
                    self.showNoResultsMessage()
                }
            }
        }
    }

    // MARK: - Loading View
    private func showLoadingView() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.textColor = .label
        label.textAlignment = .center

        view.addSubview(indicator)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        self.loadingIndicator = indicator
        self.loadingLabel = label
    }

    private func hideLoadingView() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingLabel?.removeFromSuperview()
        loadingIndicator = nil
        loadingLabel = nil
    }

    // MARK: - No Results
    private func showNoResultsMessage() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No results found."
        label.textColor = .label
        label.textAlignment = .center

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.noResultsLabel = label
    }

    // MARK: - Update UI with Results
    private func updateUIWithRecords(_ records: [ProductEntity]) {
        // Remove noResultsLabel if it was visible
        noResultsLabel?.removeFromSuperview()

        // Setup UIPageViewController
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.dataSource = self
        pvc.delegate = self
        pvc.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(pvc)
        view.addSubview(pvc.view)
        NSLayoutConstraint.activate([
            pvc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pvc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pvc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pvc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pvc.didMove(toParent: self)
        self.pageViewController = pvc

        // Set initial page
        if let firstVC = pageForProduct(at: 0) {
            pvc.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }

        // Setup UIPageControl
        let pc = UIPageControl()
        pc.numberOfPages = products.count
        pc.currentPage = 0
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.pageIndicatorTintColor = .systemGray4
        pc.currentPageIndicatorTintColor = .systemBlue

        view.addSubview(pc)
        NSLayoutConstraint.activate([
            pc.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pc.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        self.pageControl = pc
    }

    private func pageForProduct(at index: Int) -> UIViewController? {
        guard index >= 0 && index < products.count else { return nil }
        let product = products[index]
        let vc = ProductPageViewController(product: product)
        vc.pageIndex = index
        return vc
    }
}

// MARK: - UIPageViewControllerDataSource and Delegate
extension ResultsViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pvc = viewController as? ProductPageViewController else { return nil }
        let newIndex = pvc.pageIndex - 1
        return pageForProduct(at: newIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pvc = viewController as? ProductPageViewController else { return nil }
        let newIndex = pvc.pageIndex + 1
        return pageForProduct(at: newIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let currentVC = pageViewController.viewControllers?.first as? ProductPageViewController else { return }
        pageControl?.currentPage = currentVC.pageIndex
    }
}
