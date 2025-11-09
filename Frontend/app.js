// --- Global variables ---
let provider;
let signer;
let contract;
let userAddress;
let ownerAddress;

const contractAddress = "0xD9EDc1B83F6B9bbD3fcE4098Cfbd7A019532534f"; // replace with your Sepolia contract
let contractAbi; // will be loaded from abi.json

// --- DOM Elements ---
const connectButton = document.getElementById("connectButton");
const depositButton = document.getElementById("depositButton");
const withdrawButton = document.getElementById("withdrawButton");
const refreshButton = document.getElementById("refreshButton");

// --- Load ABI ---
async function loadABI() {
  const response = await fetch("abi.json");
  contractAbi = await response.json();
}

// --- Connect Wallet ---
async function connectWallet() {
  if (!window.ethereum) {
    alert("MetaMask not detected!");
    return;
  }

  try {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    provider = new ethers.BrowserProvider(window.ethereum);
    signer = await provider.getSigner();
    userAddress = await signer.getAddress();

    document.getElementById("walletAddress").innerText =
      `Connected: ${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;

    await loadABI();
    contract = new ethers.Contract(contractAddress, contractAbi, signer);

    // check owner
    ownerAddress = await contract.getowner();
    if (ownerAddress.toLowerCase() === userAddress.toLowerCase()) {
      document.getElementById("ownerCard").style.display = "block";
      document.getElementById("ownerAddress").innerText = ownerAddress;
    }

    depositButton.disabled = false;
    withdrawButton.disabled = false;
    refreshData();
  } catch (error) {
    console.error(error);
    alert("Failed to connect wallet: " + error.message);
  }
}

// --- Deposit function ---
async function deposit() {
  if (!contract) {
    alert("Connect your wallet first!");
    return;
  }

  const amount = document.getElementById("depositAmount").value;
  const status = document.getElementById("depositStatus");

  if (!amount || isNaN(amount) || Number(amount) <= 0) {
    alert("Enter a valid amount");
    return;
  }

  try {
    status.innerText = "Processing deposit...";
    const tx = await contract.deposit({ value: ethers.parseEther(amount) });
    await tx.wait();
    status.innerText = `✅ Deposited ${amount} ETH successfully!`;
    document.getElementById("depositAmount").value = "";
    refreshData();
  } catch (error) {
    console.error(error);
    status.innerText = `❌ Deposit failed: ${error?.reason || error.message}`;
  }
}

// --- Withdraw function ---
async function withdraw() {
  if (!contract) {
    alert("Connect your wallet first!");
    return;
  }

  const amount = document.getElementById("withdrawAmount").value;
  const status = document.getElementById("withdrawStatus");

  if (!amount || isNaN(amount) || Number(amount) <= 0) {
    alert("Enter a valid amount");
    return;
  }

  try {
    status.innerText = "Processing withdrawal...";
    const tx = await contract.withdraw(ethers.parseEther(amount));
    await tx.wait();
    status.innerText = `✅ Withdrawn ${amount} ETH successfully!`;
    document.getElementById("withdrawAmount").value = "";
    refreshData();
  } catch (error) {
    console.error(error);
    status.innerText = `❌ Withdrawal failed: ${error?.reason || error.message}`;
  }
}

// --- Refresh dashboard ---
async function refreshData() {
  if (!contract) return;

  try {
    // User balance
    const balanceWei = await contract.balances(userAddress);
    const balanceEth = ethers.formatEther(balanceWei);
    document.getElementById("userBalance").innerText = balanceEth;

    // Lock timer
    const lockTime = await contract.LockedTimer(userAddress);
    const currentBlock = await provider.getBlock("latest");
    const currentTime = currentBlock.timestamp;

    if (lockTime > currentTime) {
      const minutesLeft = Math.ceil((lockTime - currentTime) / 60);
      document.getElementById("lockStatus").innerText = `Locked (${minutesLeft} mins left)`;
    } else {
      document.getElementById("lockStatus").innerText = "Unlocked";
    }

    const date = new Date(lockTime * 1000);
    document.getElementById("unlockTime").innerText = date.toLocaleString();

    // Owner vault balance
    if (userAddress.toLowerCase() === ownerAddress.toLowerCase()) {
      const vaultBal = await contract.getBalance();
      document.getElementById("vaultBalance").innerText = ethers.formatEther(vaultBal);
    }
  } catch (error) {
    console.error(error);
  }
}

// --- Event listeners ---
connectButton.addEventListener("click", connectWallet);
depositButton.addEventListener("click", deposit);
withdrawButton.addEventListener("click", withdraw);
refreshButton.addEventListener("click", refreshData);

// --- Disable buttons until wallet is connected ---
depositButton.disabled = true;
withdrawButton.disabled = true;
