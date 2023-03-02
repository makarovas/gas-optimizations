pragma solidity ^0.8.0;


/* 

 Store frequently used values in memory instead of storage, or use local variables instead of state variables.

*/
contract GasOptimization1 {
    uint256 public value;

    function expensiveFunction() public {
        for (uint256 i = 0; i < 100; i++) {
            value += 1;
        }
    }

    function cheaperFunction() public {
        uint256 localValue = value;
        for (uint256 i = 0; i < 100; i++) {
            localValue += 1;
        }
        value = localValue;
    }
}


/* 


1.

The optimizedFunction uses a simple for loop to iterate over the array of values and add them to a sum variable.

The lessGasFunction uses inline assembly to load the data from the array directly from memory, which can be more efficient than accessing it through Solidity's memory allocation mechanism.

In the assembly code, the mload opcode is used to load the length of the array and the data from each element of the array, and the add and mul opcodes are used to calculate the memory addresses of the elements.

The add opcode is used to increment the sum variable for each element of the array, and the assembly block is closed with a closing brace.

By using inline assembly to directly access the memory where the array data is stored, the lessGasFunction is able to use fewer gas than the optimizedFunction for the same calculation. 


2.



The expensiveFunction function uses a for loop to iterate over the array and calculate the sum. It also includes a require statement to ensure that the array size does not exceed a maximum value, which helps prevent out-of-gas errors.

The cheapFunction function uses assembly code to perform the same calculation. Assembly is a low-level programming language that allows you to write more efficient code by directly manipulating the EVM. In this case, the assembly code iterates over the array and calculates the sum using the mload instruction, which loads a 256-bit word from memory. 



*/

contract GasOptimization2 {
    function notOptimizedFunction(uint256[] memory values) public pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < values.length; i++) {
            sum += values[i];
        }
        return sum;
    }

    function lessGasFunction(uint256[] memory values) public pure returns (uint256) {
        uint256 sum = 0;
        assembly {
            let len := mload(values)
            let data := add(values, 0x20)
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                let elem := mload(add(data, mul(i, 0x20)))
                sum := add(sum, elem)
            }
        }
        return sum;
    }



    uint256 public constant MAX_ARRAY_SIZE = 100;

    function expensiveFunction2(uint256[] memory _data) public pure returns (uint256) {
        require(_data.length <= MAX_ARRAY_SIZE, "Array too large");
        uint256 sum = 0;
        for (uint256 i = 0; i < _data.length; i++) {
            sum += _data[i];
        }
        return sum;
    }

    function cheapFunction2(uint256[] memory _data) public pure returns (uint256) {
        require(_data.length <= MAX_ARRAY_SIZE, "Array too large");
        assembly {
            let len := mload(_data)
            let data := add(_data, 32)
            let sum := 0

            for { let end := add(data, mul(len, 32)) } lt(data, end) { data := add(data, 32) } {
                sum := add(sum, mload(data))
            }

            return(sum)
        }
    }


}


/* 

bitwise operators to perform modular arithmetic on powers of two.

*/

contract GasOptimization3 {
    function expensiveMod(uint256 x) public pure returns (uint256) {
        return x % 256;
    }

    function cheaperMod(uint256 x) public pure returns (uint256) {
        return x & 0xff;
    }
}


/* 

modifiers can reduce code repetition and save gas.

*/

contract GasOptimization4 {
    uint256 public value;

    modifier checkValue(uint256 _value) {
        require(_value > 0, "Value must be greater than zero");
        _;
    }

    function expensiveFunction(uint256 _value) public checkValue(_value) {
        for (uint256 i = 0; i < 100; i++) {
            value += _value;
        }
    }

    function cheaperFunction(uint256 _value) public checkValue(_value) {
        uint256 localValue = value;
        for (uint256 i = 0; i < 100; i++) {
            localValue += _value;
        }
        value = localValue;
    }
}


/**

the expensiveFunction increments three different storage variables for each address, while the cheaperFunction groups these variables into a struct and accesses them using a local variable. This reduces the number of storage slots used by the contract and can save gas.


 */
contract GasOptimization5 {
    struct Data {
        uint256 x;
        uint256 y;
        uint256 z;
    }

    mapping(address => Data) public data;

    function expensiveFunction(address _addr) public {
        data[_addr].x += 1;
        data[_addr].y += 2;
        data[_addr].z += 3;
    }

    function cheaperFunction(address _addr) public {
        Data storage d = data[_addr];
        d.x += 1;
        d.y += 2;
        d.z += 3;
    }
}

/**

 expensiveFunction calculates the sum of an array using a for loop, which can be expensive if the array is large. The cheaperFunction returns a simple constant value. Both of these functions can be declared as view or pure, which can save gas.

 */

contract GasOptimization6 {
    uint256[] public data;

    function expensiveFunction() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        return sum;
    }

    function cheaperFunction() public pure returns (uint256) {
        return 10 * 20;
    }
}


/**

expensiveFunction calculates the sum of either an array of uint256 values or a byte array. By using function overloading, we can reuse the same function name for both operations and save gas by avoiding duplicate code.

 */
contract GasOptimization7 {
    function expensiveFunction(uint256[] memory _data) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _data.length; i++) {
            sum += _data[i];
        }
        return sum;
    }

    function lessExpensiveFunction(bytes memory _data) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _data.length; i++) {
            sum += uint256(_data[i]);
        }
        return sum;
    }
}





