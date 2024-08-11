# Iroha Node Setup Guide

## Prerequisites

- Docker and Docker Compose installed
- jq installed
- JWT token for authentication (provided by network administrator)
- Git installed

## Setup Instructions

1. **Clone Repository**
   - Clone the Iroha node setup repository:
   ```
   git clone https://github.com/fabric-mabric/iroha-node.git
   cd iroha-node
   ```

2. **JWT Token Configuration**
   - Replace the content of `.jwt-token` file with your provided JWT token.

3. **Run Setup Script**
   - Make the script executable:
   ```
   chmod +x setup.sh
   ```
   - Execute the `setup.sh` script:
   ```
   ./setup.sh
   ```
   This script will:
   - Generate key pairs for your Iroha node
   - Fetch the genesis public key
   - Retrieve trusted peers information

4. **Launch Iroha Node**
   Start the Iroha node using Docker Compose:
   ```
   docker-compose up -d
   ```

5. **Secure Key Storage**
   - Save generated keypair to somewhere safe.

6. **Public Key Submission**
   - Locate your P2P address and public key in the `.submission` file.
   - Send this information to the network administrator via a secure channel.

## Notes
After network administrator has added your node to trusted peers, your node will start syncing with the network and will be able to participate in the consensus.