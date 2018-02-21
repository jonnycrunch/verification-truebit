pragma solidity ^0.4.17;

import "./IVerifiable.sol";
import "./ITrueBit.sol";


contract JobsManager is IVerifiable {
    // IPFS hash used to download the WASM binary containing verification code
    // that is run by Truebit solvers and verifiers
    string public codeHash;
    // String of identifiers that correspond to a video profiles defining
    // the required values for fields such as resolution, framerate, bitrate, etc.
    // for a transcoded video segment
    // In the simplest case, this string just contains a single video profile identifier
    string public transcodingOptions;
    // Contract entry point into TrueBit system
    ITrueBit public trueBit;

    event ReceivedVerification(bool passed);

    modifier onlyTrueBit() {
        require(msg.sender == address(trueBit));
        _;
    }

    function JobsManager(address _trueBit, string _codeHash, string _transcodingOptions) public {
        codeHash = _codeHash;
        transcodingOptions = _transcodingOptions;
        trueBit = ITrueBit(_trueBit);
    }

    function verify(string _dataIPFSHash) external payable {
        trueBit.add(codeHash, _dataIPFSHash);
    }

    function receiveVerification(string _transcodingOptions) external onlyTrueBit {
        if (keccak256(_transcodingOptions) == keccak256(transcodingOptions)) {
            ReceivedVerification(true);
        } else {
            ReceivedVerification(false);
        }
    }
}
