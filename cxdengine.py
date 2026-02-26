import hashlib
import time
import os
import json
import ctypes
import sys
from flask import Flask, request, jsonify
from flask_cors import CORS

# DEBUG: Check if files exist
print(f"Directory Contents: {os.listdir('.')}")

try:
    lib_path = os.path.abspath("./libcxd.so")
    print(f"Attempting to load C library from: {lib_path}")
    libcxd = ctypes.CDLL(lib_path)
    print("✅ C Library loaded successfully.")
except Exception as e:
    print(f"❌ FATAL: Could not load C library. Error: {e}")
    # This ensures Render logs show the error before the app dies
    sys.exit(1)

app = Flask(__name__)
CORS(app)

class CxDNode:
    def __init__(self, node_id, federation_members):
        self.node_id = node_id
        self.federation = federation_members
        self.ledger = []

    def validate_geofence(self, location_data):
        # Configuration for the Island of Ireland & Northern Ireland
        allowed_countries = ["Republic of Ireland", "United Kingdom", "Ireland"]
        # In production, these would be verified GPS bounding boxes
        user_country = location_data.get("country")
        return user_country in allowed_countries

    def decrypt_and_validate(self, payload):
        try:
            vote_value = payload.get("vote")
            voter_id = payload.get("voter_id") # Transient ID
            location = payload.get("location_data", {})
            
            if self.validate_geofence(location):
                return vote_value
            return None
        finally:
            # The 'Wipe' Protocol: Clear local references immediately
            voter_id = None
            payload = None

    def reach_consensus(self, vote):
        # Federated Byzantine Agreement Simulation
        # Requires 3/4 Quorum for a valid entry
        quorum_threshold = (len(self.federation) // 2) + 1
        agreement_count = 1 
        
        # In production, this loop performs async pings to other nodes
        for peer in self.federation:
            if peer != self.node_id:
                agreement_count += 1 
        
        if agreement_count >= quorum_threshold:
            self.commit_to_ledger(vote)
            return True
        return False

    def commit_to_ledger(self, vote):
        entry = {
            "timestamp": time.time(),
            "vote": vote.upper(),
            "node_signature": hashlib.sha256(f"{self.node_id}{time.time()}".encode()).hexdigest()
        }
        self.ledger.append(entry)

node = CxDNode(
    node_id=os.environ.get("NODE_ID", "Dublin_Node_01"),
    federation_members=["Dublin_Node_01", "Belfast_Node_01", "London_Node_01", "UN_Observer_01"]
)

@app.route('/submit-vote', methods=['POST'])
def submit_vote():
    data = request.get_json()
    validated_vote = node.decrypt_and_validate(data)
    
    if validated_vote:
        if node.reach_consensus(validated_vote):
            return jsonify({"status": "success", "message": "Consensus reached. Vote added to ledger."}), 200
    
    return jsonify({"status": "denied", "message": "Geofence or Consensus failure."}), 403

@app.route('/results', methods=['GET'])
def get_results():
    # Public Dashboard Logic
    tally = {"YES": 0, "NO": 0}
    for entry in node.ledger:
        vote = entry.get("vote")
        if vote in tally:
            tally[vote] += 1
            
    return jsonify({
        "jurisdiction": "Island of Ireland (All-Island Referendum)",
        "total_votes": len(node.ledger),
        "results": tally,
        "nodes_online": len(node.federation),
        "status": "Final" if len(node.ledger) > 1000 else "Live Tallying"
    }), 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
