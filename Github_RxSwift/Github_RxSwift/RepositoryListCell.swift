//
//  RepositoryListCell.swift
//  Github_RxSwift
//
//  Created by 김우섭 on 11/24/23.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    
    var repository: Repository?
    
    let nameLable = UILabel()
    let decriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLabel = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
            nameLable, decriptionLabel,
            starImageView, starLabel, languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        guard let repository = repository else { return }
        nameLable.text = repository.name
        nameLable.font = .systemFont(ofSize: 15, weight: .bold)
        
        decriptionLabel.text = repository.description
        decriptionLabel.font = .systemFont(ofSize: 15)
        decriptionLabel.numberOfLines = 2
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.text = "\(repository.stargazersCount)"
        starLabel.font = .systemFont(ofSize: 16)
        starLabel.textColor = .gray
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 16)
        languageLabel.textColor = .gray
        
        nameLable.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        
        decriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLable.snp.bottom).offset(3)
            $0.leading.trailing.equalTo(nameLable)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(decriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(decriptionLabel)
            $0.width.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        starLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        
        languageLabel.snp.makeConstraints {
            $0.centerY.equalTo(starLabel)
            $0.leading.equalTo(starLabel.snp.trailing).offset(12)
        }
    }
}
