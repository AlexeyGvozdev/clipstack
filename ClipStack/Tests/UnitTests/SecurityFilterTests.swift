//
//  SecurityFilterTests.swift
//  ClipStack
//
//  Created by Alexey Gvozdev on 31.01.2026.
//

import XCTest
@testable import ClipStack

final class SecurityFilterTests: XCTestCase {
    var securityFilter: SecurityFilter!
    
    override func setUp() {
        super.setUp()
        securityFilter = SecurityFilter()
    }
    
    override func tearDown() {
        securityFilter = nil
        super.tearDown()
    }
    
    // MARK: - Password Detection Tests
    
    func testDetectsPasswordPattern() {
        let testCases = [
            "password: mySecretPass123",
            "Password=SuperSecret!",
            "pwd: admin123",
            "PASSWD: test",
            "password:noSpaces"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect password in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .password)
        }
    }
    
    func testDoesNotDetectNonPasswordText() {
        let testCases = [
            "This is a normal text",
            "password",  // Just the word without value
            "My password is secure"  // Casual mention
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertFalse(result.isSensitive, "Should not detect password in: \(testCase)")
        }
    }
    
    // MARK: - Credit Card Detection Tests
    
    func testDetectsCreditCardNumbers() {
        let testCases = [
            "4532015112830366",  // Visa
            "5425233430109903",  // Mastercard
            "374245455400126",   // Amex
            "4532 0151 1283 0366",  // With spaces
            "4532-0151-1283-0366"   // With dashes
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect credit card in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .creditCard)
        }
    }
    
    func testDoesNotDetectNonCreditCardNumbers() {
        let testCases = [
            "123",
            "12345",
            "Phone: 555-1234"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            // May detect as credit card if matches pattern, but shouldn't for short numbers
            if result.isSensitive {
                XCTAssertNotEqual(result.detectedPattern, .creditCard, "Should not detect as credit card: \(testCase)")
            }
        }
    }
    
    // MARK: - API Key Detection Tests
    
    func testDetectsAPIKeys() {
        let testCases = [
            "api_key: sk_live_51H7Xj2KZvKYlo2C",
            "API-KEY=AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe",
            "apikey: \"ghp_1234567890abcdefghijklmnopqrst\"",
            "access_key: AKIAIOSFODNN7EXAMPLE"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect API key in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .apiKey)
        }
    }
    
    // MARK: - Private Key Detection Tests
    
    func testDetectsPrivateKeys() {
        let privateKey = """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF0K3j8v8
        -----END RSA PRIVATE KEY-----
        """
        
        let result = securityFilter.isSensitive(privateKey)
        XCTAssertTrue(result.isSensitive)
        XCTAssertEqual(result.detectedPattern, .privateKey)
    }
    
    func testDetectsPrivateKeyHeader() {
        let testCases = [
            "-----BEGIN PRIVATE KEY-----",
            "-----BEGIN RSA PRIVATE KEY-----"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect private key in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .privateKey)
        }
    }
    
    // MARK: - Token Detection Tests
    
    func testDetectsJWTTokens() {
        let testCases = [
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
            "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect JWT token in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .token)
        }
    }
    
    // MARK: - Email Detection Tests
    
    func testDetectsEmailAddresses() {
        let testCases = [
            "user@example.com",
            "john.doe@company.co.uk",
            "admin+test@domain.org"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect email in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .email)
        }
    }
    
    // MARK: - Phone Detection Tests
    
    func testDetectsPhoneNumbers() {
        let testCases = [
            "+1 (555) 123-4567",
            "555-123-4567",
            "+44 20 7946 0958",
            "1234567890"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect phone in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .phone)
        }
    }
    
    // MARK: - SSN Detection Tests
    
    func testDetectsSSN() {
        let testCases = [
            "123-45-6789",
            "SSN: 987-65-4321"
        ]
        
        for testCase in testCases {
            let result = securityFilter.isSensitive(testCase)
            XCTAssertTrue(result.isSensitive, "Should detect SSN in: \(testCase)")
            XCTAssertEqual(result.detectedPattern, .ssn)
        }
    }
    
    // MARK: - Multiple Patterns Detection Tests
    
    func testDetectsMultiplePatterns() {
        let content = """
        User: john@example.com
        Password: secret123
        API Key: sk_live_1234567890
        """
        
        let detected = securityFilter.detectAllPatterns(content)
        XCTAssertTrue(detected.contains(.email))
        XCTAssertTrue(detected.contains(.password))
        XCTAssertTrue(detected.contains(.apiKey))
        XCTAssertEqual(detected.count, 3)
    }
    
    // MARK: - Empty Content Tests
    
    func testEmptyContentIsNotSensitive() {
        let result = securityFilter.isSensitive("")
        XCTAssertFalse(result.isSensitive)
        XCTAssertNil(result.detectedPattern)
    }
    
    func testEmptyContentDetectsNoPatterns() {
        let detected = securityFilter.detectAllPatterns("")
        XCTAssertTrue(detected.isEmpty)
    }
    
    // MARK: - Convenience Method Tests
    
    func testContainsSensitiveData() {
        XCTAssertTrue(securityFilter.containsSensitiveData("password: test123"))
        XCTAssertFalse(securityFilter.containsSensitiveData("Hello, world!"))
    }
    
    // MARK: - Custom Filter Tests
    
    func testCriticalOnlyFilter() {
        let filter = SecurityFilter.criticalOnly()
        
        // Should detect critical patterns
        XCTAssertTrue(filter.containsSensitiveData("password: test"))
        XCTAssertTrue(filter.containsSensitiveData("4532015112830366"))
        
        // Should not detect non-critical patterns
        XCTAssertFalse(filter.containsSensitiveData("user@example.com"))
        XCTAssertFalse(filter.containsSensitiveData("555-123-4567"))
    }
    
    func testStrictWithoutContactsFilter() {
        let filter = SecurityFilter.strictWithoutContacts()
        
        // Should detect sensitive patterns
        XCTAssertTrue(filter.containsSensitiveData("password: test"))
        
        // Should not detect email and phone
        XCTAssertFalse(filter.containsSensitiveData("user@example.com"))
        XCTAssertFalse(filter.containsSensitiveData("555-123-4567"))
    }
    
    // MARK: - Pattern Description Tests
    
    func testPatternDescriptions() {
        XCTAssertEqual(SecurityFilter.SensitivePattern.password.description, "Password")
        XCTAssertEqual(SecurityFilter.SensitivePattern.creditCard.description, "Credit Card Number")
        XCTAssertEqual(SecurityFilter.SensitivePattern.apiKey.description, "API Key")
        XCTAssertEqual(SecurityFilter.SensitivePattern.privateKey.description, "Private Key")
        XCTAssertEqual(SecurityFilter.SensitivePattern.token.description, "Authentication Token")
    }
    
    // MARK: - Real-World Scenarios Tests
    
    func testRealWorldPasswordScenario() {
        let content = """
        To access the server, use:
        username: admin
        password: P@ssw0rd123!
        """
        
        let result = securityFilter.isSensitive(content)
        XCTAssertTrue(result.isSensitive)
        XCTAssertEqual(result.detectedPattern, .password)
    }
    
    func testRealWorldAPIKeyScenario() {
        let content = """
        # Configuration
        export API_KEY=sk_live_51H7Xj2KZvKYlo2C
        export DATABASE_URL=postgres://localhost
        """
        
        let result = securityFilter.isSensitive(content)
        XCTAssertTrue(result.isSensitive)
        XCTAssertEqual(result.detectedPattern, .apiKey)
    }
    
    func testSafeContentIsNotDetected() {
        let safeContent = """
        This is a normal text document.
        It contains no sensitive information.
        Just regular words and sentences.
        """
        
        let result = securityFilter.isSensitive(safeContent)
        XCTAssertFalse(result.isSensitive)
        XCTAssertNil(result.detectedPattern)
    }
}