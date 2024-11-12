//
//  LoginViewController.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 12/11/24.
//
import UIKit
import SnapKit
import MSBCoreUI
import Combine
import CombineCocoa

final class LoginViewController: UIViewController {
    // MARK: - Properties
    var viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()

    private let loadingView = MSBLoadingView()

    private lazy var loginButton: UIButton = {
        let v = UIButton()
        v.setTitle("Đăng nhập", for: .normal)
        return v
    }()
    
    // MARK: - Initialisation
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.send()
    }

    // MARK: - Private methods
        
    private func setupLayout() {
        loginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel
            .$screenState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }
                switch state {
                case .initial:
                    self.hideLoadingView()
                case .loading:
                    self.showLoadingView()
                case .authenticated:
                    break
                case .hasError:
                    self.hideLoadingView()
                }
            })
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.onEvent(.login)
            }
            .store(in: &cancellables)
    }
    
    private func setupView() {
        view.addSubview(loginButton)
        view.addSubview(loadingView)
        setupLayout()
    }
    
    private func showLoadingView() {
        loadingView.isHidden = false
        loadingView.startAnimating()
    }
    
    private func hideLoadingView(){
        loadingView.isHidden = true
        loadingView.stopAnimating()
    }

}
