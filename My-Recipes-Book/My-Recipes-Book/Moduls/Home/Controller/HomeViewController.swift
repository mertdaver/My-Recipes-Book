//
//  HomeViewController.swift
//  My-Recipes-Book
//
//  Created by Михаил Болгар on 28.08.2023.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    //MARK: - Temporary data source
    let categoriesArray = ["There will", "Be some more", "Text here", "But not", "Just now"]
    
    //MARK: - Propperties
    
    let headerKind = UICollectionView.elementKindSectionHeader
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createCompositionalLayout() )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TrendingCollectionViewCell.self, forCellWithReuseIdentifier: TrendingCollectionViewCell.reuseID)
        collectionView.register(PopularCategoryCollectionViewCell.self, forCellWithReuseIdentifier: PopularCategoryCollectionViewCell.reuseID)
        collectionView.register(PopularItemCollectionViewCell.self, forCellWithReuseIdentifier: PopularItemCollectionViewCell.reuseID)
        collectionView.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.reuseID)
        collectionView.register(PopularCreatorCollectionViewCell.self, forCellWithReuseIdentifier: PopularCreatorCollectionViewCell.reuseID)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: headerKind, withReuseIdentifier: HeaderCollectionReusableView.reuseID)
        //collectionView.backgroundColor = .yellow
        return collectionView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.isActive = true
        controller.searchBar.placeholder = "Search recepies"
        return controller
    }()
    
    //MARK: - Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlets()
        setupConstraints()
    }
    
    //MARK: - Methods
    private func setOutlets() {
        view.backgroundColor = .cyan
        title = "Get amazing recepies for cooking"
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(collectionView)
        
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

//MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case SectionType.trending.rawValue:
            return 10
        case SectionType.popularCategory.rawValue:
            return categoriesArray.count
        case SectionType.popularItem.rawValue:
            return 10
        case SectionType.recentRecipe.rawValue:
            return 10
        case SectionType.popularCreator.rawValue:
            return 10
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case SectionType.trending.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCollectionViewCell.reuseID, for: indexPath)
            return cell
        case SectionType.popularCategory.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularCategoryCollectionViewCell.reuseID, for: indexPath) as? PopularCategoryCollectionViewCell else {return .init()}
            cell.setup(with: categoriesArray[indexPath.item])
            return cell
        case SectionType.popularItem.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularItemCollectionViewCell.reuseID, for: indexPath) as? PopularItemCollectionViewCell else {return.init()}
            cell.setupCell()
            return cell
        case SectionType.recentRecipe.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.reuseID, for: indexPath)
            return cell
        case SectionType.popularCreator.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularCreatorCollectionViewCell.reuseID, for: indexPath)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == headerKind {
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.reuseID, for: indexPath) as? HeaderCollectionReusableView else {return .init()}
            header.setup(setHeaderData(for: indexPath))
            return header
        }
        return .init()
    }
    
    private func setHeaderData(for indexPath: IndexPath) -> (title: String, isHidden: Bool) {
        var title: String
        var isHidden: Bool
        switch indexPath.section {
        case SectionType.trending.rawValue :
            title = "Trending now 🔥"
            isHidden = false
        case SectionType.popularCategory.rawValue:
            title = "Popular category"
            isHidden = true
        case SectionType.popularItem.rawValue:
            title = ""
            isHidden = true
        case SectionType.recentRecipe.rawValue:
            title = "Recent recipe"
            isHidden = false
        case SectionType.popularCreator.rawValue:
            title = "Popular creators"
            isHidden = false
        default:
            title = ""
            isHidden = true
        }
        return (title, isHidden)
    }
    
}

//MARK: - Compositional layout creation
extension HomeViewController {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, layoutEnviroment in
            switch sectionNumber {
            case SectionType.trending.rawValue:
                return self.createTrendingSection()
            case SectionType.popularCategory.rawValue:
                return self.createPopularCategorySection()
            case SectionType.popularItem.rawValue:
                return self.createPopularItemSection()
            case SectionType.recentRecipe.rawValue:
                return self.createRecentRecipeSection()
            case SectionType.popularCreator.rawValue:
                return self.createPopularCreatorSection()
            default: return nil
            }
        }
        return layout
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(54))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: headerKind,
            alignment: .top)
        return layoutSectionHeader
    }
    
    private func createTrendingSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(280/375),
            heightDimension: .fractionalWidth(254/375))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createPopularCategorySection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(150),//fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(150),//fractionalWidth(1/4),
            heightDimension: .absolute(34))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [createSectionHeader()]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 19, trailing: 0)
        return section
    }
    
    private func createPopularItemSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(150/375),
            heightDimension: .fractionalWidth(231/375))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
    private func createRecentRecipeSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(124/375),
            heightDimension: .fractionalWidth(190/375))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createPopularCreatorSection() -> NSCollectionLayoutSection {
        //item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        //group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(110/375),
            heightDimension: .fractionalWidth(136/375))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        //section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
}