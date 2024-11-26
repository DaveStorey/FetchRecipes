//
//  Fetch_RecipesTests.swift
//  Fetch RecipesTests
//
//  Created by David Storey on 11/22/24.
//

import XCTest
@testable import Fetch_Recipes

class APIClientTests: XCTestCase {

    // Mock URLSession for testing
    class MockURLSession: URLSession, @unchecked Sendable {
        var data: Data?
        var error: Error?
        
        override init() { }

    }
    
    class MockAPIClient: APIClient {
        var session: MockURLSession
        
        init(session: MockURLSession) {
            self.session = session
        }
        
        override func fetchRecipes() async throws -> RecipeList {
            if let error = session.error {
                throw error
            }
            let recipeList = try JSONDecoder().decode(RecipeList.self, from: session.data ?? Data())
            return recipeList
        }
    }

    var apiClient: APIClient!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        apiClient = MockAPIClient(session: mockSession)
    }

    override func tearDown() {
        apiClient = nil
        mockSession = nil
        super.tearDown()
    }

    // Test for successful response with a valid RecipeList
    func testFetchRecipes_Success() async {
        // Given
        let mockRecipesData = """
        {
            "recipes": [
            {
                "cuisine": "Tunisian",
                "name": "Tunisian Orange Cake",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/903015fb-7bc2-426b-aa1b-724d0007ce30/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/903015fb-7bc2-426b-aa1b-724d0007ce30/small.jpg",
                "source_url": "http://allrecipes.co.uk/recipe/16067/tunisian-orange-cake.aspx",
                "uuid": "a1bedde3-2bc6-46f9-ab3c-0d98a2b11b64",
                "youtube_url": "https://www.youtube.com/watch?v=rCUxg866Ea4"
            },
            {
                "cuisine": "Croatian",
                "name": "Walnut Roll Gužvara",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/8f60cd87-20ab-419b-a425-56b7ad7c8566/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/8f60cd87-20ab-419b-a425-56b7ad7c8566/small.jpg",
                "source_url": "https://www.visit-croatia.co.uk/croatian-cuisine/croatian-recipes/",
                "uuid": "7d6a2c69-f0ef-459a-abf5-c2e90b6555ff",
                "youtube_url": "https://www.youtube.com/watch?v=Q_akngSJVrQ"
            },
            {
                "cuisine": "French",
                "name": "White Chocolate Crème Brûlée",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/f4b7b7d7-9671-410e-bf81-39a007ede535/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/f4b7b7d7-9671-410e-bf81-39a007ede535/small.jpg",
                "source_url": "https://www.bbcgoodfood.com/recipes/2540/white-chocolate-crme-brle",
                "uuid": "ef7d81b7-07ba-4fab-a791-ae10e2817e66",
                "youtube_url": "https://www.youtube.com/watch?v=LmJ0lsPLHDc"
            }
            ]
        }
        """.data(using: .utf8)
        mockSession.data = mockRecipesData
        do {
            let recipeList = try await apiClient.fetchRecipes()
            
            XCTAssertEqual(recipeList.recipes.count, 2)
            XCTAssertEqual(recipeList.recipes[0].name, "Spaghetti Carbonara")
            XCTAssertEqual(recipeList.recipes[1].cuisine, "American")
        } catch {
            XCTFail("Expected success, but got failure: \(error)")
        }
    }

    // Test for failure response due to network error
    func testFetchRecipes_Failure_NetworkError() async {
        // Given
        mockSession.error = URLError.invalidURL

        // When
        do {
            _ = try await apiClient.fetchRecipes()
            XCTFail("Expected failure, but got success")
        } catch let error {
            // Then
            XCTAssertNotNil(error)
        }
    }

    // Test for failure response due to invalid JSON
    func testFetchRecipes_Failure_InvalidJSON() async {
        //Given
        let invalidJSON = """
        "{
            "recipes": [
            {
                "cuisine": "Malaysian",
                "name": "Apam Balik",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            },
            {
                "cuisine": "British",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
                "source_url": "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
                "uuid": "599344f4-3c5c-4cca-b914-2210e3b3312f",
                "youtube_url": "https://www.youtube.com/watch?v=4vhcOwVBDO4"
            },
            {
                "cuisine": "British",
                "name": "Apple Frangipan Tart",
                "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jpg",
                "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg",
                "uuid": "74f6d4eb-da50-4901-94d1-deae2d8af1d1",
                "youtube_url": "https://www.youtube.com/watch?v=rp8Slv4INLk"
            }
        ]
    }
    """.data(using: .utf8)
    
        mockSession.data = invalidJSON
        // When
        do {
            _ = try await apiClient.fetchRecipes()
            XCTFail("Expected failure, but got success")
        } catch let error {
            // Then
            XCTAssertNotNil(error)
        }
    }
}
