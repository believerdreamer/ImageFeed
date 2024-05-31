import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("liteplay03@ya.ru")
        sleep(1)
        app.buttons["Done"].tap()
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        sleep(1)
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        sleep(1)
        passwordTextField.tap()
        passwordTextField.typeText("Z4IAWNdwpk_@")
        app.buttons["Done"].tap()
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        sleep(1)
        
        webView.webViews.buttons["Login"].tap()
        sleep(5)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(5)
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        cellToLike.buttons["LikeButton"].tap()
        sleep(5)
        cellToLike.tap()
        sleep(5)
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        let navBackButtonWhiteButton = app.buttons["BackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    
    
    func testProfile() throws {
        func testProfile() throws {
            sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
           
            XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            app.buttons["logout button"].tap()
            
            app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        }
        
    }
}
