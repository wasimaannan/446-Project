// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract PatientData {
    struct Patient {
        uint id;
        uint age;
        string gender;
        string vaccineStatus;
        string district;
        string symptomsDetails;
        bool isDead;
    }

    mapping(address => Patient) public patients;
    address[] public patientAddresses; // Array to store patient addresses

    event PatientAdded(address patientAddress);
    event VaccineStatusUpdated(address patientAddress, string newStatus);
    event DeathStatusUpdated(address patientAddress, bool isDead);

    function addPatient(address _patientAddress, uint _id, uint _age, string memory _gender, string memory _vaccineStatus, string memory _district, string memory _symptomsDetails) public {
        require(patients[_patientAddress].id == 0, "Patient already exists");

        patients[_patientAddress] = Patient(_id, _age, _gender, _vaccineStatus, _district, _symptomsDetails, false);
        patientAddresses.push(_patientAddress); // Add patient address to the array
        
        emit PatientAdded(_patientAddress);
    }

    function updateVaccineStatus(address _patientAddress, string memory _newStatus) public {
        require(bytes(patients[_patientAddress].vaccineStatus).length != 0, "Patient does not exist");
        require(keccak256(bytes(_newStatus)) == keccak256("not_vaccinated") || keccak256(bytes(_newStatus)) == keccak256("one_dose") || keccak256(bytes(_newStatus)) == keccak256("two_dose"), "Invalid vaccine status");

        patients[_patientAddress].vaccineStatus = _newStatus;
        emit VaccineStatusUpdated(_patientAddress, _newStatus);
    }

    function updateDeathStatus(address _patientAddress, bool _isDead) public {
        require(bytes(patients[_patientAddress].vaccineStatus).length != 0, "Patient does not exist");

        patients[_patientAddress].isDead = _isDead;
        emit DeathStatusUpdated(_patientAddress, _isDead);
    }

    function getPatient(address _patientAddress) public view returns (uint, uint, string memory, string memory, string memory, string memory, bool) {
        Patient memory patient = patients[_patientAddress];
        return (patient.id, patient.age, patient.gender, patient.vaccineStatus, patient.district, patient.symptomsDetails, patient.isDead);
    }

    function getPatientsCount() public view returns (uint) {
        return patientAddresses.length;
    }
}
