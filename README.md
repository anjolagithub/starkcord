# **StarkCord**

**StarkCord** is a decentralized platform on **StarkNet** that revolutionizes project funding with **milestone-based investments**. It ensures funds are released only when milestones are met, providing **transparency**, **security**, and **accountability**.

---

## **Key Features**

- 🚀 **Milestone-Based Funding**: Projects receive funds in stages as milestones are achieved.  
- 🔍 **Validator System**: Independent validators verify milestone completion before fund release.  
- 🔒 **Secure Investments**: Funds are held in smart contracts until verified.  
- 🪙 **Native Token (STRC)**: Used for investments and rewards.  

---

## **How It Works**

### **For Project Owners**
1. **Create projects** with predefined milestones.  
2. **Update progress** and submit proofs for validation.  
3. **Receive funds** upon validator approval.  

### **For Investors**
1. **Browse** and invest in projects using STRC tokens.  
2. **Track progress** via transparent blockchain records.  
3. **Funds are securely held** until milestones are met.  

### **For Validators**
1. **Review and verify** milestone submissions.  
2. **Approve fund releases**.  
3. **Earn rewards** and build reputation.  

---

## **Benefits**

- **Project Owners**: Access funding without upfront collateral, structured milestones, and enhanced credibility.  
- **Investors**: Minimized risk, secure funds, and transparent tracking.  
- **Validators**: Active role in project success and rewards for validation.  

---

## **Smart Contract Architecture**

### **1. StarkCord Token (STRC)**
- **Standard**: ERC20 with minting capabilities.  
- **Functions**:  
  - `name()`  
  - `symbol()`  
  - `balance_of()`  
  - `transfer()`  
  - `mint()`  

### **2. Core Contract**
- **Manages**: Project creation and milestone tracking.  
- **Functions**:  
  - `create_project()`  
  - `get_project()`  
  - `update_milestone()`  

### **3. Investment Contract**
- **Handles**: Investments and fund releases.  
- **Functions**:  
  - `invest()`  
  - `release()`  
  - `add_validator()`  

---

## **Installation and Setup**

### **Prerequisites**
- [Scarb](https://docs.swmansion.com/scarb/)  
- [Starkli](https://github.com/Shard-Labs/starkli)  
- **StarkNet Sepolia Testnet Access**  

### **Steps**
1. Clone the repository:  
   ```bash
   git clone https://github.com/anjolagithub/starkcord.git
   cd starkcord
   ```
2. Install dependencies:  
   ```bash
   scarb install
   ```
3. Build contracts:  
   ```bash
   scarb build
   ```

### **Account Setup**
1. Create a keystore:  
   ```bash
   starkli signer keystore new ~/.starkli-wallets/deployer.json
   ```
2. Initialize an account:  
   ```bash
   starkli account oz init ~/.starkli-wallets/account.json
   ```
3. Set environment variables:  
   ```bash
   export STARKNET_KEYSTORE="~/.starkli-wallets/deployer.json"
   export STARKNET_ACCOUNT="~/.starkli-wallets/account.json"
   ```

---

## **Usage Guide**

### **Create a Project**
```bash
starkli invoke --account ~/.starkli-wallets/account.json --watch $CORE_CONTRACT create_project 0x01 u256:1000000000000000000
```

### **Make an Investment**
1. Approve token spending:  
   ```bash
   starkli invoke --account ~/.starkli-wallets/account.json --watch $TOKEN_CONTRACT approve $INVESTMENT_CONTRACT u256:1000000000000000000
   ```
2. Invest in a project:  
   ```bash
   starkli invoke --account ~/.starkli-wallets/account.json --watch $INVESTMENT_CONTRACT invest 0x01 u256:1000000000000000000
   ```

### **Check Project Status**
```bash
starkli call $CORE_CONTRACT get_project 0x01
```

---

## **Contract Addresses (Sepolia Testnet)**

- **Token (STRC)**: `0x07d8bb07a782764cb7549bbed8e41614cc213d9d9cbba6ea6ee4c8b628391de7`  
- **Core Contract**: `0x004e86bab0159377ecfb9268444f4e1323edaab55826b21a9027cad066b60cd5`  
- **Investment Contract**: `0x075e3f1ac639e250111c33c589c7292639e77e0510e3cc7f29b411f3e89e902e`  

---

## **Development**

### **Build Contracts**
```bash
scarb build
```

### **Run Tests**
```bash
scarb test
```

### **Deploy Contracts**
1. Deploy the token:  
   ```bash
   starkli deploy --account ~/.starkli-wallets/account.json --watch $CLASS_HASH name symbol initial_supply recipient
   ```
2. Deploy core and investment contracts similarly.

---

## **Contributing**

1. Fork the repository.  
2. Create a feature branch.  
3. Commit and push changes.  
4. Open a Pull Request.  

