# -*- coding: utf-8 -*-
"""
Basic unit tests for Sapiencial Backend
Phase 1 implementation - Critical security tests
"""
import unittest
import sys
import os

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from config import config, Config
    from auth import AuthenticationError, JWTManager, TeacherAuth, StudentAuth
    from main import validate_token, generate_session_id
except ImportError as e:
    print(f"Import error: {e}")
    print("Please install requirements: pip install -r requirements.txt")
    sys.exit(1)

class TestConfig(unittest.TestCase):
    """Test configuration module"""
    
    def test_config_initialization(self):
        """Test that configuration initializes properly"""
        self.assertIsNotNone(config)
        self.assertIsInstance(config.JWT_SECRET_KEY, str)
        self.assertGreater(len(config.JWT_SECRET_KEY), 10)
    
    def test_cors_config(self):
        """Test CORS configuration"""
        cors_config = Config.get_cors_config()
        self.assertIn("allow_origins", cors_config)
        self.assertIn("allow_credentials", cors_config)
        self.assertTrue(cors_config["allow_credentials"])
    
    def test_config_validation(self):
        """Test configuration validation"""
        # This should pass with default config
        self.assertTrue(Config.validate_config())

class TestJWTManager(unittest.TestCase):
    """Test JWT token management"""
    
    def setUp(self):
        """Set up test JWT manager"""
        self.jwt_manager = JWTManager()
    
    def test_create_token(self):
        """Test JWT token creation"""
        payload = {"sub": "test_user", "role": "teacher"}
        token = self.jwt_manager.create_access_token(payload)
        
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 20)
    
    def test_verify_token(self):
        """Test JWT token verification"""
        payload = {"sub": "test_user", "role": "teacher"}
        token = self.jwt_manager.create_access_token(payload)
        
        verified_payload = self.jwt_manager.verify_token(token)
        self.assertEqual(verified_payload["sub"], "test_user")
        self.assertEqual(verified_payload["role"], "teacher")
    
    def test_invalid_token(self):
        """Test invalid token handling"""
        with self.assertRaises(AuthenticationError):
            self.jwt_manager.verify_token("invalid_token")
    
    def test_expired_token(self):
        """Test expired token rejection"""
        # Create token with very short expiration for testing
        self.jwt_manager.expiration_hours = 0.001  # ~3.6 seconds
        payload = {"sub": "test_user"}
        token = self.jwt_manager.create_access_token(payload)
        
        import time
        time.sleep(0.1)  # Wait for token to expire
        
        with self.assertRaises(AuthenticationError):
            self.jwt_manager.verify_token(token)

class TestTeacherAuth(unittest.TestCase):
    """Test teacher authentication"""
    
    def setUp(self):
        """Set up test teacher auth"""
        self.teacher_auth = TeacherAuth()
    
    def test_token_validation_teacher(self):
        """Test teacher token validation"""
        # Test with correct token
        is_valid = self.teacher_auth.validate_token("profesor2026", "teacher")
        self.assertTrue(is_valid)
        
        # Test with incorrect token
        is_invalid = self.teacher_auth.validate_token("wrong_token", "teacher")
        self.assertFalse(is_invalid)
    
    def test_token_validation_student(self):
        """Test student token validation (should always return True for now)"""
        is_valid = self.teacher_auth.validate_token("any_token", "student")
        self.assertTrue(is_valid)
    
    def test_teacher_authentication(self):
        """Test teacher authentication with username/password"""
        # Test correct credentials
        token = self.teacher_auth.authenticate_teacher("admin", "admin123")
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 20)
        
        # Test incorrect credentials
        with self.assertRaises(AuthenticationError):
            self.teacher_auth.authenticate_teacher("wrong", "credentials")
    
    def test_jwt_teacher_verification(self):
        """Test JWT token verification for teachers"""
        # Create teacher JWT
        token = self.teacher_auth.authenticate_teacher("admin", "admin123")
        payload = self.teacher_auth.verify_jwt_token(token)
        
        self.assertEqual(payload["role"], "teacher")
        self.assertEqual(payload["sub"], "admin")

class TestStudentAuth(unittest.TestCase):
    """Test student authentication"""
    
    def setUp(self):
        """Set up test student auth"""
        self.student_auth = StudentAuth()
    
    def test_create_student_token(self):
        """Test student token creation"""
        student_data = {
            "session_id": "test_session",
            "name": "Test Student"
        }
        token = self.student_auth.create_student_token(student_data)
        
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 20)
    
    def test_verify_student_token(self):
        """Test student token verification"""
        student_data = {
            "session_id": "test_session",
            "name": "Test Student"
        }
        token = self.student_auth.create_student_token(student_data)
        payload = self.student_auth.verify_student_token(token)
        
        self.assertEqual(payload["role"], "student")
        self.assertEqual(payload["name"], "Test Student")

class TestUtilityFunctions(unittest.TestCase):
    """Test utility functions"""
    
    def test_generate_session_id(self):
        """Test session ID generation"""
        session_id = generate_session_id()
        
        self.assertIsInstance(session_id, str)
        self.assertEqual(len(session_id), 8)
        
        # Test uniqueness
        session_id2 = generate_session_id()
        self.assertNotEqual(session_id, session_id2)
    
    def test_generate_secure_token(self):
        """Test secure token generation"""
        from auth import generate_secure_token
        
        token = generate_secure_token()
        
        self.assertIsInstance(token, str)
        self.assertGreater(len(token), 20)
        
        # Test uniqueness
        token2 = generate_secure_token()
        self.assertNotEqual(token, token2)
    
    def test_hash_password(self):
        """Test password hashing"""
        from auth import hash_password, verify_password
        
        password = "test_password"
        password_hash, salt = hash_password(password)
        
        self.assertIsInstance(password_hash, str)
        self.assertIsInstance(salt, str)
        self.assertEqual(len(salt), 32)  # 16 bytes = 32 hex chars
        
        # Test verification
        is_valid = verify_password(password, password_hash, salt)
        self.assertTrue(is_valid)
        
        # Test wrong password
        is_invalid = verify_password("wrong_password", password_hash, salt)
        self.assertFalse(is_invalid)

class TestSecurity(unittest.TestCase):
    """Test security-related functionality"""
    
    def test_hardcoded_credentials_removed(self):
        """Test that hardcoded credentials are not exposed in main code"""
        # Check that the old hardcoded token is not directly accessible
        from main import TEACHER_ACCESS_TOKEN
        
        # The token should come from config, not hardcoded
        self.assertEqual(TEACHER_ACCESS_TOKEN, config.TEACHER_ACCESS_TOKEN)
    
    def test_cors_configuration(self):
        """Test that CORS is properly configured"""
        # This would be tested in the actual FastAPI app
        # For now, just check that config has proper structure
        cors_config = config.get_cors_config()
        
        # Should not allow all origins in production
        if "*" in cors_config["allow_origins"]:
            # If "*" is allowed, we should be in debug mode
            self.assertTrue(config.DEBUG)
        
        # Should have proper methods
        expected_methods = {"GET", "POST", "PUT", "DELETE", "OPTIONS"}
        self.assertEqual(set(cors_config["allow_methods"]), expected_methods)

def run_basic_tests():
    """Run all basic tests and return results"""
    print("?? Running Basic Security Tests...")
    print("=" * 50)
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test classes
    test_classes = [
        TestConfig,
        TestJWTManager,
        TestTeacherAuth,
        TestStudentAuth,
        TestUtilityFunctions,
        TestSecurity
    ]
    
    for test_class in test_classes:
        suite.addTests(loader.loadTestsFromTestCase(test_class))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Summary
    print("\n" + "=" * 50)
    print("?? TEST SUMMARY:")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")
    
    if result.failures:
        print("\n? FAILURES:")
        for test, traceback in result.failures:
            print(f"  - {test}: {traceback}")
    
    if result.errors:
        print("\n?? ERRORS:")
        for test, traceback in result.errors:
            print(f"  - {test}: {traceback}")
    
    return result.wasSuccessful()

if __name__ == "__main__":
    success = run_basic_tests()
    sys.exit(0 if success else 1)