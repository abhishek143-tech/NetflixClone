//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by Abhishek Dilip Dhok on 22/08/23.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}

/*
 {
etag = "7UboJMIrQupqmQDzXlM_1RJx7Zk";
id =             {
 kind = "youtube#video";
 videoId = "71xBu_VHTfY";
};
kind = "youtube#searchResult";
}
 */
