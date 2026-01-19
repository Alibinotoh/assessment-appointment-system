from neo4j import GraphDatabase
from config import get_settings
from typing import Optional, List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class Neo4jService:
    def __init__(self):
        settings = get_settings()
        self.driver = GraphDatabase.driver(
            settings.NEO4J_URI,
            auth=(settings.NEO4J_USERNAME, settings.NEO4J_PASSWORD),
            max_connection_lifetime=3600,
            max_connection_pool_size=50,
            connection_acquisition_timeout=120,
            connection_timeout=30,
            keep_alive=True
        )
        self._verify_connection()
    
    def _verify_connection(self):
        """Verify connection to Neo4j Aura"""
        try:
            with self.driver.session() as session:
                result = session.run("RETURN 1 as test")
                result.single()
                logger.info("✅ Successfully connected to Neo4j Aura")
        except Exception as e:
            logger.error(f"❌ Failed to connect to Neo4j: {e}")
            raise
    
    def close(self):
        self.driver.close()
    
    def execute_query(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute a Cypher query and return results with retry logic"""
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                with self.driver.session() as session:
                    result = session.run(query, parameters or {})
                    return [record.data() for record in result]
            except Exception as e:
                retry_count += 1
                if retry_count >= max_retries:
                    logger.error(f"Query failed after {max_retries} retries: {e}")
                    raise
                logger.warning(f"Query retry {retry_count}/{max_retries} after error: {e}")
                import time
                time.sleep(1 * retry_count)
    
    def execute_write(self, query: str, parameters: Dict[str, Any] = None) -> Optional[Dict[str, Any]]:
        """Execute a write transaction with retry logic"""
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                with self.driver.session() as session:
                    result = session.write_transaction(
                        lambda tx: tx.run(query, parameters or {}).single()
                    )
                    return result.data() if result else None
            except Exception as e:
                retry_count += 1
                if retry_count >= max_retries:
                    logger.error(f"Failed after {max_retries} retries: {e}")
                    raise
                logger.warning(f"Retry {retry_count}/{max_retries} after error: {e}")
                import time
                time.sleep(1 * retry_count)  # Exponential backoff

# Singleton instance
neo4j_service = Neo4jService()
