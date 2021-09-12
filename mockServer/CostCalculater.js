function costCal(mainProductID, mainCost, secProdroductID, secCost) {
    let cost = mainCost + secCost;
    if (mainProductID.substr(0,2) == secProdroductID.substr(0,2)) {
        cost *= 0.6;
    }
    return cost;
}