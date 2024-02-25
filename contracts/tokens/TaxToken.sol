// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
/*
Thank you for the support.
We are going to the moon.
Follow our journey and join the community:
- Twitter: Project Profile
- Telegram: Project Profile
- Discord: Project Profile
- Visit our Website: Project Website
*/

interface IPulseXRouter01 {
    function factory() external pure returns (address);
    function WPLS() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPulseXRouter02 is IPulseXRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPulseXFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IWPLS {
    function balanceOf(address) external returns(uint256);
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract TaxToken is ERC20, Ownable {
    uint256 public constant MAX_TOTAL_SUPPLY = 1000_000_000_000 ether; // Total Supply
    uint256 public constant MIN_HOLDING_FOR_REWARDS = 1e8 * 1e18; // Minimal Holder Rewards
    uint256 public maxWalletToken = (MAX_TOTAL_SUPPLY * 5) / (10 * 100); // 0.5% of max total supply

    // Taxes
    uint256 public buyHolderRewardTax = 1;
    uint256 public buyProjectDevelopmentTax = 1;
    uint256 public buyLiquidityTax = 1;
    
    uint256 public sellHolderRewardTax = 1;
    uint256 public sellProjectDevelopmentTax = 1;
    uint256 public sellLiquidityTax = 3;

    address public projectDevelopmentWallet;

    // PulseXRouter02
    // mainnet: 0x165C3410fC91EF562C50559f7d2289fEbed552d9
    // testnet: 0x636f6407B90661b73b1C0F7e24F4C79f624d0738
    address public router = 0x165C3410fC91EF562C50559f7d2289fEbed552d9;

    IPulseXRouter02 private immutable pulsexRouter;
    address public immutable taxPLSPair;
    bool public inSwapAndLiquify;
    bool public isTradeOpen = false;

    mapping(address => bool) public isExcludedFee;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() ERC20("Test", "TST") Ownable() {
        _mint(msg.sender, MAX_TOTAL_SUPPLY);
        // _mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, MAX_TOTAL_SUPPLY);
        
        projectDevelopmentWallet = msg.sender;
        IPulseXRouter02 _pulsexRouter = IPulseXRouter02(router);

        taxPLSPair = IPulseXFactory(_pulsexRouter.factory()).createPair(address(this), _pulsexRouter.WPLS());

        // set the rest of the contract variables
        pulsexRouter = _pulsexRouter;
        isExcludedFee[msg.sender] = true;
        isExcludedFee[address(this)] = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        uint256 taxForHolderRewards = 0;
        uint256 taxForProjectDevelopment = 0;
        uint256 taxForLiquidity = 0;
        uint256 taxes = 0;
        uint256 amountAfterTax = amount;

        bool isExcluded = isExcludedFee[sender] || isExcludedFee[recipient];
        
        super._transfer(sender, address(this), amount);

        if (!isExcluded) {
            if (_isSell(sender, recipient)) {
                taxForHolderRewards = (amount * sellHolderRewardTax) / 100;
                taxForProjectDevelopment = (amount * sellProjectDevelopmentTax) / 100;
                taxForLiquidity = (amount * sellLiquidityTax) / 100;
                taxes = (taxForHolderRewards + taxForProjectDevelopment + taxForLiquidity);
            
                amountAfterTax = amount - taxes;

                // logic holder rewards
                if (balanceOf(recipient) >= MIN_HOLDING_FOR_REWARDS)
                    super._transfer(address(this), recipient, taxForProjectDevelopment);

                // logic project development wallet
                super._transfer(address(this), projectDevelopmentWallet, taxForProjectDevelopment);
                
                // logic auto liquidity

                addLiquidityToken(taxForLiquidity, msg.sender);

            } else if (_isBuy(sender, recipient)) {
                taxForHolderRewards = (amount * buyHolderRewardTax) / 100;
                taxForProjectDevelopment = (amount * buyProjectDevelopmentTax) / 100;
                taxForLiquidity = (amount * buyLiquidityTax) / 100;
                taxes = (taxForHolderRewards + taxForProjectDevelopment + taxForLiquidity);
                amountAfterTax = amount - taxes;

                // logic holder rewards
                if (balanceOf(recipient) >= MIN_HOLDING_FOR_REWARDS)
                    super._transfer(address(this), recipient, taxForProjectDevelopment);

                // logic project development wallet
                super._transfer(address(this), projectDevelopmentWallet, taxForProjectDevelopment);

                // logic auto liquidity
                // addLiquidityToken (taxForLiquidity, msg.sender);
            }
        }
        
        super._transfer(address(this), recipient, amountAfterTax);
    }

    function addLiquidityToken(uint256 _tax, address _to) internal lockTheSwap {

        _approve(address(this), address(pulsexRouter), _tax);

        address[] memory path = new address[](2);
        path[0] = address(this);  // Token address (assuming it's the contract's token)
        path[1] = pulsexRouter.WPLS();  // WPLS address from the router

        // (uint256[] memory amounts) = pulsexRouter.swapExactTokensForETH(
        //     _tax,
        //     0,
        //     path,
        //     address(this),
        //     block.timestamp + 100
        // );

        pulsexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tax,
            0,
            path,
            address(this),
            block.timestamp
        );

        pulsexRouter.addLiquidity(
            path[0], path[1],
            _tax, IWPLS(pulsexRouter.WPLS()).balanceOf(address(this)), 0, 0, 
            _to,
            block.timestamp + 100
        );
    }

    function _isSell(address sender, address recipient) private view returns (bool) {
        return sender != address(0) && recipient == taxPLSPair;
    }

    function _isBuy(address sender, address recipient) private view returns (bool) {
        return recipient != address(0) && sender == taxPLSPair;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(msg.sender) >= amount, "ERC20: transfer amount exceeds balance");
        
        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function changeProjectDevelopmentWallet(address payable _newProjectDevelopmentWallet) external {
        require(msg.sender == projectDevelopmentWallet, "Only developer could change this address");
        projectDevelopmentWallet = _newProjectDevelopmentWallet;
    }

}