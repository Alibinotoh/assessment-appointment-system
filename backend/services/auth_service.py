from services.neo4j_service import neo4j_service
from utils.security import verify_password, create_access_token, hash_password
from fastapi import HTTPException, status
from datetime import timedelta
from config import get_settings

settings = get_settings()

class AuthService:
    
    @staticmethod
    def authenticate_counselor(email: str, password: str) -> dict:
        """
        Authenticate counselor/admin and return JWT token
        """
        query = """
        MATCH (c:Counselor {email: $email})
        RETURN c.counselor_id as counselor_id, 
               c.full_name as full_name,
               c.email as email,
               c.password_hash as password_hash
        """
        
        result = neo4j_service.execute_query(query, {"email": email})
        
        if not result:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        counselor = result[0]
        
        # Verify password
        if not verify_password(password, counselor["password_hash"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )
        
        # Generate JWT token
        access_token = create_access_token(
            data={
                "sub": counselor["counselor_id"],
                "email": counselor["email"]
            },
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "counselor_id": counselor["counselor_id"],
            "full_name": counselor["full_name"],
            "email": counselor["email"]
        }
    
    @staticmethod
    def create_counselor(full_name: str, email: str, employee_id: str, 
                        specialization: str, password: str) -> str:
        """
        Create a new counselor account (for initial setup)
        """
        import uuid
        counselor_id = str(uuid.uuid4())
        password_hash = hash_password(password)
        
        query = """
        CREATE (c:Counselor {
            counselor_id: $counselor_id,
            full_name: $full_name,
            email: $email,
            employee_id: $employee_id,
            specialization: $specialization,
            password_hash: $password_hash,
            created_at: datetime()
        })
        RETURN c.counselor_id as counselor_id
        """
        
        result = neo4j_service.execute_write(query, {
            "counselor_id": counselor_id,
            "full_name": full_name,
            "email": email,
            "employee_id": employee_id,
            "specialization": specialization,
            "password_hash": password_hash
        })
        
        return result["counselor_id"]

auth_service = AuthService()
