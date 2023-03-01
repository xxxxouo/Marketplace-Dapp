import { ethers } from "ethers";
import MarketplaceJSON from "../Marketplace.json";


const getContract = (abi, address) => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  return new ethers.Contract(address, abi, signer);
};


export const getMarketContract = () => {
  return getContract(MarketplaceJSON.abi, MarketplaceJSON.address);
};
