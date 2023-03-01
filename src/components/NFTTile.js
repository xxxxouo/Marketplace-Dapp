import axie from "../tile.jpeg";
import { ethers } from "ethers";
import {
    BrowserRouter as Router,
    Link,
  } from "react-router-dom";
import { getMarketContract } from "../hooks";
import { useEffect, useState } from "react";

function NFTTile (data) {
    const contract = getMarketContract()
    const [state,setState] = useState(true) 
    const newTo = {
        pathname:"/nftPage/"+data.data.tokenId
    }
    const handleBtn = async(e) =>{
      e.preventDefault()
      const tx = await contract.onShelveToken(data.data.tokenId,ethers.utils.parseUnits("0.01",'ether'),{value:ethers.utils.parseUnits("0.01",'ether')})
      await tx.wait()
    }

    useEffect(()=>{
      const getInfo = async()=>{
        const res  = await contract.getListedForTokenId(data.data.tokenId)
        setState(res.currentlyListed);
      }
      getInfo()
    },[])
    return (
        <Link to={newTo}>
          <div className="border-2 ml-12 mt-5 mb-12 flex flex-col items-center rounded-lg w-48 md:w-72 shadow-2xl">
              <img src={data.data.image} alt="" className="w-72 h-80 rounded-lg object-cover" />
              <div className= "text-white w-full p-2 bg-gradient-to-t from-[#454545] to-transparent rounded-lg pt-5 -mt-24">
                  <strong className="text-xl">{data.data.name}</strong>
                  <p className="display-inline">
                      {data.data.description}
                  </p>
                  {
                    !state &&
                    <button onClick={handleBtn} className=" bg-blue-400 px-5 rounded-md">sell for 0.01eth</button>
                  }
              </div>
          </div>
        </Link>
    )
}

export default NFTTile;
