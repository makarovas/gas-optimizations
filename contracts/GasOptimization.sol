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


/**

Almost similar GasOptimization2 example, but uses a combination of Solidity and inline assembly code to optimize gas usage. The cheapFunction first loads the length of the array and a pointer to its data using Solidity's built-in memory layout. It then iterates over the array using inline assembly, using the mload instruction to load each uint256 value from memory and add it to the sum. Finally, it returns the sum using Solidity's built-in return mechanism.

This approach provides the benefits of both Solidity and inline assembly: it is more efficient than the for loop in terms of gas usage, but still uses Solidity's memory layout and return mechanism, making it easier to read and write than pure inline assembly code.



 */



contract GasOptimization8 {
    function expensiveFunction(uint256[] memory _data) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _data.length; i++) {
            sum += _data[i];
        }
        return sum;
    }

    function cheapFunction(uint256[] memory _data) public pure returns (uint256) {
        uint256 sum = 0;

        assembly {
            let len := mload(_data)
            let data := add(_data, 32)

            for { let end := add(data, mul(len, 32)) } lt(data, end) { data := add(data, 32) } {
                sum := add(sum, mload(data))
            }
        }

        return sum;
    }
}


/**

The expensiveFunction uses Solidity's built-in storage keyword to load the MyStruct into memory, update its fields, and store it back to storage. The cheapFunction, on the other hand, uses inline assembly to directly manipulate storage, which can be more efficient in terms of gas usage.

The cheapFunction first computes the storage slot for the caller's MyStruct using the keccak256 hash function. It then uses inline assembly to store the four uint256 values directly to storage at the computed slot. Note that this approach requires a fixed layout for the MyStruct to ensure that the values are stored in the correct order.

 */

contract GasOptimization9 {
    struct MyStruct {
        uint256 value1;
        uint256 value2;
        uint256 value3;
        uint256 value4;
    }

    mapping(address => MyStruct) private myStructs;

    function expensiveFunction() public {
        MyStruct storage myStruct = myStructs[msg.sender];
        myStruct.value1 += 1;
        myStruct.value2 += 2;
        myStruct.value3 += 3;
        myStruct.value4 += 4;
    }

    function cheapFunction() public {
        bytes32 slot = keccak256(abi.encodePacked(msg.sender));
        assembly {
            let ptr := add(msize(), 1)
            sstore(slot, ptr)
            mstore(ptr, 1)
            mstore(add(ptr, 32), 2)
            mstore(add(ptr, 64), 3)
            mstore(add(ptr, 96), 4)
        }
    }
}



/**

 The expensiveFunction uses Solidity's built-in push function to append each value in _data to myArray. The cheapFunction, on the other hand, uses inline assembly to append the values to a memory array instead of a storage array, which can be more efficient in terms of gas usage.

The cheapFunction first loads the length of myArray and computes a pointer to the end of the array in memory. It then uses inline assembly to loop over each value in _data, using the mload instruction to load each uint256 value from memory and store it in the appropriate position in the memory array. Finally, it updates the length of myArray in storage using the sstore instruction.

 */


contract GasOptimization10 {
    uint256[] private myArray;

    function expensiveFunction(uint256[] memory _data) public {
        for (uint256 i = 0; i < _data.length; i++) {
            myArray.push(_data[i]);
        }
    }

    function cheapFunction(uint256[] memory _data) public {
        uint256 length = myArray.length;
        assembly {
            let ptr := add(msize(), 1)
            for { let i := 0 } lt(i, mload(_data)) { i := add(i, 1) } {
                mstore(add(ptr, mul(add(length, i), 32)), mload(add(_data, mul(i, 32))))
            }
            sstore(add(keccak256(abi.encodePacked(myArray)), 1), add(length, mload(_data)))
        }
    }
}


/**

The expensiveFunction uses standard Solidity syntax to perform these operations in a loop, while the cheapFunction uses inline assembly to optimize the operations and reduce gas costs.

The cheapFunction first loads the input values into memory using the mstore instruction, and then uses inline assembly to perform the same series of operations as the expensiveFunction. However, instead of using separate Solidity statements for each operation, the cheapFunction combines multiple operations into a single inline assembly block. This reduces the number of Solidity instructions and results in lower gas costs.

 */
contract GasOptimization11 {
    function expensiveFunction(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < 100; i++) {
            result += a + b + c;
            result *= 2;
            result -= c * b;
        }
        return result;
    }

    function cheapFunction(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
        uint256 result;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, a)
            mstore(add(ptr, 32), b)
            mstore(add(ptr, 64), c)
            for { let i := 0 } lt(i, 100) { i := add(i, 1) } {
                let x := mload(ptr)
                let y := mload(add(ptr, 32))
                let z := mload(add(ptr, 64))
                x := add(x, y)
                x := add(x, z)
                x := mul(x, 2)
                x := sub(x, mul(y, z))
                mstore(ptr, x)
            }
            result := mload(ptr)
        }
        return result;
    }
}