//
//  BlogListCell.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import UIKit
import SnapKit
import Kingfisher

// 블로그 리스트를 표시하기 위한 테이블 뷰 셀
class BlogListCell: UITableViewCell {
    let thumbnailImageView = UIImageView() // 썸네일 이미지 뷰
    let nameLabel = UILabel() // 블로그 이름 라벨
    let titleLabel = UILabel() // 글 제목 라벨
    let datetimeLabel = UILabel() // 작성 일자 라벨
    
    // 셀의 서브뷰 레이아웃 설정
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 썸네일 이미지 뷰의 컨텐츠 모드 설정
        thumbnailImageView.contentMode = .scaleAspectFit
        
        // 라벨들의 폰트 및 라인 수 설정
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.numberOfLines = 2
        datetimeLabel.font = .systemFont(ofSize: 12, weight: .light)
        
        // 서브뷰들을 콘텐츠 뷰에 추가
        [thumbnailImageView, nameLabel, titleLabel, datetimeLabel].forEach {
            contentView.addSubview($0)
        }
        
        // SnapKit을 사용하여 서브뷰들의 레이아웃 제약 조건 설정
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
            $0.trailing.lessThanOrEqualTo(thumbnailImageView.snp.leading).offset(-8)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.trailing.bottom.equalToSuperview().inset(8)
            $0.width.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(thumbnailImageView.snp.leading).offset(-8)
        }
        
        datetimeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(titleLabel)
            $0.bottom.equalTo(thumbnailImageView)
        }
    }
    
    // 셀에 데이터 설정
    func setData(_ data: BlogListCellData) {
        // Kingfisher를 사용하여 썸네일 이미지 로드
        thumbnailImageView.kf.setImage(with: data.thumbnailURL, placeholder: UIImage(systemName: "photo"))
        nameLabel.text = data.name // 블로그 이름 설정
        titleLabel.text = data.title // 글 제목 설정
        
        // 날짜 형식을 지정하여 표시
        var datetime: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 mm월 dd일"
            let contentDate = data.datetime ?? Date()
            
            return dateFormatter.string(from: contentDate)
        }
        
        datetimeLabel.text = datetime // 작성 일자 표시
    }
}
