//
//  IssueDetailViewController.swift
//  IssueTracker
//
//  Created by 조기현 on 2020/10/31.
//  Copyright © 2020 남기범. All rights reserved.
//

import UIKit

class SectionItem: Hashable {
	let identifier = UUID()
	
	static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
}

class IssueComment: SectionItem {
	let author: String
	let content: String
	init(author: String, content: String) {
		self.author = author
		self.content = content
	}
}

class IssueDetailViewController: UIViewController {
	typealias DataSource = UICollectionViewDiffableDataSource<Section, IssueComment>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, IssueComment>
	
	@IBOutlet weak var collectionView: UICollectionView!
	var issue: Issue!
	var commentList = [IssueComment]()
	var dataSource: DataSource?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		// setup collection view
		setupCollectionView()
		setupDataSource()
		applySnapshot()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateIssueDetail()
	}
	
	func updateIssueDetail() {
		commentList = [
			IssueComment(author: "godrm",
						 content: "레이블 전체 목록을 볼 수 있는게 어떨까요\n 전체 설명이 보여야 선택할 수 있으니까\n\n마크다운 문법을 지원하고 \n HTML형태로 보여줘야 할까요"),
			IssueComment(author: "crong",
						 content: "긍정적인 기능이네요\n 댓글은 두 줄"),
			IssueComment(author: "honux",
						 content: "안녕하세요 호눅스입니다")
		]
		applySnapshot()
	}
	
	// MARK: - Tab bar item Actions
	@IBAction func backButton(_ sender: UIBarButtonItem) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func editButton(_ sender: UIBarButtonItem) {
	}
}

// MARK: - Setup Collection View, Layout and Datasource
extension IssueDetailViewController {
	func setupCollectionView() {
		collectionView.collectionViewLayout = createLayout()
		
		collectionView.register(UINib(nibName: "IssueDetailHeaderReusableView", bundle: nil),
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
								withReuseIdentifier: IssueDetailHeaderReusableView.identifier)
		
		collectionView.register(UINib(nibName: "IssueDetailCommentViewCell", bundle: nil),
								forCellWithReuseIdentifier: IssueDetailCommentViewCell.identifier)
	}
	
	func setupDataSource() {
		dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
			guard let cell = collectionView
					.dequeueReusableCell(withReuseIdentifier: IssueDetailCommentViewCell.identifier,
										 for: indexPath) as? IssueDetailCommentViewCell
			else { return nil }
			
			cell.issueComment = item
			return cell
		}
		
		dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
			guard kind == UICollectionView.elementKindSectionHeader,
				  let headerView = collectionView.dequeueReusableSupplementaryView(
					ofKind: kind,
					withReuseIdentifier: IssueDetailHeaderReusableView.identifier,
					for: indexPath) as? IssueDetailHeaderReusableView
			else { return nil }
			
			headerView.issue = self.issue
			return headerView
		}
	}
	
	func applySnapshot(animatingDifferences: Bool = true) {
		var snapShot = Snapshot()
		snapShot.appendSections([.main])
		snapShot.appendItems(commentList, toSection: .main)
		dataSource?.apply(snapShot, animatingDifferences: animatingDifferences)
	}
	
	func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
			var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
			configuration.backgroundColor = .systemGroupedBackground
			configuration.showsSeparators = false
			
			let section = NSCollectionLayoutSection.list(
				using: configuration,
				layoutEnvironment: layoutEnvironment
			)
			
			let headerSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(1000)
			)
			let header = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerSize,
				elementKind: UICollectionView.elementKindSectionHeader,
				alignment: .top
			)
			
			section.boundarySupplementaryItems = [header]
			section.contentInsets = NSDirectionalEdgeInsets(
				top: 20, leading: 0, bottom: 0, trailing: 0
			)
			section.interGroupSpacing = 20
			
			return section
		}
		return layout
	}
}
