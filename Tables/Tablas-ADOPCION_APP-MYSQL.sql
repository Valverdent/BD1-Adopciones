-- ==========================================
-- == Creacion tablas esquema ADOPCION_APP ==
-- ==========================================

-- Correr desde ROOT o ADOPCION_APP

-- Selecciono esquema de destino
USE ADOPCION_APP;

-- Tablas usadas para direcciones 
CREATE TABLE IF NOT EXISTS Country (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS Province (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idCountry   INT(7) NOT NULL,
    name        VARCHAR(60) NOT NULL,    
    
    CONSTRAINT province_country_fk FOREIGN KEY (idCountry) REFERENCES Country (id)
);

CREATE TABLE IF NOT EXISTS Canton (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idProvince  INT(7) NOT NULL,
    name        VARCHAR(60) NOT NULL,
    
    CONSTRAINT canton_province_fk FOREIGN KEY (idProvince) REFERENCES Province (id)
);

CREATE TABLE IF NOT EXISTS District (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    idCanton    INT(7) NOT NULL,
    name    VARCHAR(60) NOT NULL,
    
    CONSTRAINT district_canton_fk FOREIGN KEY (idCanton) REFERENCES Canton (id)
);

CREATE TABLE IF NOT EXISTS Location (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    idDistrict    INT(7) NOT NULL,
    address    VARCHAR(255) NOT NULL,
    
    CONSTRAINT location_district_fk FOREIGN KEY (idDistrict) REFERENCES District (id)
);


-- Tablas utlizadas para la table persona y sus subtablas consecuentes
CREATE TABLE IF NOT EXISTS Person (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idLocation  INT(7) NOT NULL,
    first_Name        VARCHAR(30) NOT NULL,
    middle_Name       VARCHAR(30),
    first_LastName    VARCHAR(30) NOT NULL,
    second_LastName   VARCHAR(30),

    CONSTRAINT person_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id)
);

CREATE TABLE IF NOT EXISTS BlackList (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,
    blackListDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    blackListReason VARCHAR(255) NOT NULL,

    CONSTRAINT blacklist_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
);

CREATE TABLE IF NOT EXISTS ContactEmail (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,
    email       VARCHAR(254), -- Limite superior de caracteres definido siguiendo estándar RFC 5321, sección 4.5.3.1 
                                        -- Cambio realizado por claridad, ya que en Modelo Lógico se define erróneamente como 'name'
    CONSTRAINT contactEmail_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
);

CREATE TABLE IF NOT EXISTS ContactNumber (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,
    phoneNumber VARCHAR(254) NOT NULL, -- Limite superior de caracteres definido siguiendo norma E.164 de la ITU (Unión Internacional de Telecounicaciones)
                                        -- Cambio realizado por claridad, ya que en Modelo Lógico se define erróneamente como 'name'
    CONSTRAINT ContactNumber_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
);


-- Tablas pertenecientes a usuario
CREATE TABLE IF NOT EXISTS UserStatus (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS `Role` (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS `User` (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,
    idRole      INT(7) NOT NULL,
    idUserStatus    INT(7) NOT NULL,
    username    VARCHAR(50) NOT NULL, -- UNIQUE para asegurar que no se pueda repetir un mismo username en la base de datos
    password    VARCHAR(64) NOT NULL, -- 64 ya que al encriptarse la contraseña usando SHA-256, este encrptado producirá un hash de 64 caracteres, por tanto, se guarda el atributo de esta manera

    CONSTRAINT user_idPerson_fk FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT user_idRole_fk FOREIGN KEY (idRole) REFERENCES `Role` (id),
    CONSTRAINT user_idUserStatus_fk FOREIGN KEY (idUserStatus) REFERENCES UserStatus (id),
    CONSTRAINT user_username_uk UNIQUE (username)
);





-- Tablas relacionadas a la tabla Pet

CREATE TABLE IF NOT EXISTS PetSize (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetColor (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetSeverity (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetEnergy (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetTrainability (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetStatus (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetType (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL      
);

CREATE TABLE IF NOT EXISTS PetBreed (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPetType INT(7) NOT NULL,
    name    VARCHAR(30) NOT NULL,

    CONSTRAINT petBreed_petType_fk FOREIGN KEY (idPetType) REFERENCES PetType (id)
);

CREATE TABLE IF NOT EXISTS Veterinarian (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,

    CONSTRAINT veterinarian_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
);

CREATE TABLE IF NOT EXISTS Pet (
    id              INT(7) AUTO_INCREMENT PRIMARY KEY,
    idLocation      INT(7) NOT NULL,
    idPerson        INT(7) NOT NULL,
    idPetBreed      INT(7) NOT NULL,
    idPetSize       INT(7) NOT NULL,
    idPetColor      INT(7) NOT NULL,
    idPetSeverity   INT(7) NOT NULL,
    idPetEnergy     INT(7) NOT NULL,
    idPetTrainability   INT(7) NOT NULL,
    idPetStatus     INT(7) NOT NULL,
    idVeterinarian  INT(7) NOT NULL,
    chipId          INT(7) NOT NULL,
    name            VARCHAR(30) NOT NULL,
    requiresSpace   TINYINT(1) NOT NULL
                                CONSTRAINT pet_requiresSpace_chk CHECK (requiresSpace IN (1,0)),
    notesDescription    VARCHAR(255) NOT NULL,
    abandonmentNotesDescription    VARCHAR(255),
    estimatedAge    INT(7),
    eventDate       DATE,

    CONSTRAINT pet_Location_fk FOREIGN KEY (idLocation) REFERENCES Location (id),
    CONSTRAINT pet_Person_fk FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT pet_PetBreed_fk FOREIGN KEY (idPetBreed) REFERENCES PetBreed (id),
    CONSTRAINT pet_PetSize_fk FOREIGN KEY (idPetSize) REFERENCES PetSize (id),
    CONSTRAINT pet_PetColor_fk FOREIGN KEY (idPetColor) REFERENCES PetColor (id),
    CONSTRAINT pet_PetSeverity_fk FOREIGN KEY (idPetSeverity) REFERENCES PetSeverity (id),
    CONSTRAINT pet_PetEnergy_fk FOREIGN KEY (idPetEnergy) REFERENCES PetEnergy (id),
    CONSTRAINT pet_PetTrainability_fk FOREIGN KEY (idPetTrainability) REFERENCES PetTrainability (id),
    CONSTRAINT pet_PetStatus_fk FOREIGN KEY (idPetStatus) REFERENCES PetStatus (id),
    CONSTRAINT pet_Veterinarian_fk FOREIGN KEY (idVeterinarian) REFERENCES Veterinarian (id)
);

CREATE TABLE IF NOT EXISTS Medication (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Treatment (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS Disease (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS Medication_x_treatment (
    idMedication    INT(7),
    idTreatment    INT(7),
    dosage      VARCHAR(100) NOT NULL,

    PRIMARY KEY (idMedication, idTreatment),
    CONSTRAINT medication_x_treatment_medication_fk FOREIGN KEY (idMedication) REFERENCES Medication (id),
    CONSTRAINT medication_x_treatment_treatment_fk FOREIGN KEY (idTreatment) REFERENCES Treatment (id)
);

CREATE TABLE IF NOT EXISTS Treatment_x_disease (
    idDisease    INT(7),
    idTreatment    INT(7),
    timeLength  VARCHAR(100) NOT NULL,

    PRIMARY KEY (idDisease, idTreatment),
    CONSTRAINT treatment_x_disease_treatment_fk FOREIGN KEY (idTreatment) REFERENCES Treatment (id),
    CONSTRAINT treatment_x_disease_disease_fk FOREIGN KEY (idDisease) REFERENCES Disease (id)
);

CREATE TABLE IF NOT EXISTS Disease_x_pet (
    idDisease    INT(7),
    idPet    INT(7),

    PRIMARY KEY (idDisease, idPet),
    CONSTRAINT disease_x_pet_disease_fk FOREIGN KEY (idDisease) REFERENCES Disease (id),
    CONSTRAINT disease_x_pet_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id)
);



-- Tablas utilizadas para donaciones
CREATE TABLE IF NOT EXISTS DonationType (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS CurrencyType (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS AnimalWelfareAssociation (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idLocation  INT(7) NOT NULL,
    name        VARCHAR(60) NOT NULL,

    CONSTRAINT animalWelfareAssociation_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id)
);

CREATE TABLE IF NOT EXISTS Reward (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPet   INT(7) NOT NULL,
    idCurrencyType   INT(7) NOT NULL,
    amount  INT(9) NOT NULL,

    CONSTRAINT reward_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id),
    CONSTRAINT reward_currencyType_fk FOREIGN KEY (idCurrencyType) REFERENCES CurrencyType (id)
);

CREATE TABLE IF NOT EXISTS Donation (
    id              INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson        INT(7) NOT NULL,
    idDonationType  INT(7) NOT NULL,
    idCurrencyType  INT(7) NOT NULL,
    idReward        INT(7) NOT NULL,
    donationDate    DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT donation_idPerson FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT donation_idDonationType FOREIGN KEY (idDonationType) REFERENCES DonationType (id),
    CONSTRAINT donation_idCurrencyType FOREIGN KEY (idCurrencyType) REFERENCES CurrencyType (id),
    CONSTRAINT donation_idReward FOREIGN KEY (idReward) REFERENCES Reward (id)
);

CREATE TABLE IF NOT EXISTS DonationDetail (
    idAnimalWelfareAssociation INT(7),
    idDonation  INT(7),
    amount      INT(9) NOT NULL,
    percentage  INT(3) NOT NULL,

    PRIMARY KEY (idAnimalWelfareAssociation, idDonation),
    CONSTRAINT donationDetail_animalWelfareAssociation_fk FOREIGN KEY (idAnimalWelfareAssociation) REFERENCES AnimalWelfareAssociation (id),
    CONSTRAINT donationDetail_donation_fk FOREIGN KEY (idDonation) REFERENCES Donation (id)
);



-- Tablas usadas para el proceso de adopcion
CREATE TABLE IF NOT EXISTS ExerciseTime (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    value   VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS HouseType (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS House (
    id              INT(7) AUTO_INCREMENT PRIMARY KEY,
    idHouseType     INT(7) NOT NULL,
    hasYard         TINYINT(1) NOT NULL
                                CONSTRAINT house_hasYard_chk CHECK (hasYard IN (1,0)),

    CONSTRAINT house_houseType_fk FOREIGN KEY (idHouseType) REFERENCES HouseType (id)
);

CREATE TABLE IF NOT EXISTS Adopter (
    idAdopter       INT(7) PRIMARY KEY,
    idHouse         INT(7) NOT NULL,
    idExerciseTime  INT(7) NOT NULL,    

    CONSTRAINT adopter_person_fk FOREIGN KEY (idAdopter) REFERENCES Person (id),
    CONSTRAINT adopter_house_fk FOREIGN KEY (idHouse) REFERENCES House (id),
    CONSTRAINT adopter_exerciseTime_fk FOREIGN KEY (idExerciseTime) REFERENCES ExerciseTime (id)
);

CREATE TABLE IF NOT EXISTS Adoption (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPerson    INT(7) NOT NULL,
    idAdopter   INT(7) NOT NULL,
    idPet       INT(7) NOT NULL,
    adoptionDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT adoption_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT adoption_adopter_fk FOREIGN KEY (idAdopter) REFERENCES Adopter (idAdopter),
    CONSTRAINT adoption_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id)
);

CREATE TABLE IF NOT EXISTS FollowUp (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idAdoption  INT(7) NOT NULL,
    comments    VARCHAR(255) NOT NULL,
    followUpDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT followUp_adoption_fk FOREIGN KEY (idAdoption) REFERENCES Adoption (id)
);

CREATE TABLE IF NOT EXISTS PetOwnerRating (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idAdoption  INT(7) NOT NULL,
    rating      INT(2) NOT NULL,
    notes       VARCHAR(255) NOT NULL,

    CONSTRAINT petOwnerRating_adoption_fk FOREIGN KEY (idAdoption) REFERENCES Adoption (id)
);

CREATE TABLE IF NOT EXISTS OtherPet (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idPetBreed  INT(7) NOT NULL,
    idAdopter   INT(7) NOT NULL,

    CONSTRAINT otherPet_petBreed_fk FOREIGN KEY (idPetBreed) REFERENCES PetBreed (id),
    CONSTRAINT otherPet_adopter_fk FOREIGN KEY (idAdopter) REFERENCES Adopter (idAdopter)
);

CREATE TABLE IF NOT EXISTS PhotoType (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS Photo (
    id          INT(7) AUTO_INCREMENT PRIMARY KEY,
    idFollowUp  INT(7) NOT NULL,
    idPet       INT(7) NOT NULL,
    idPhotoType INT(7) NOT NULL,
    photoURL    VARCHAR(2048) NOT NULL,  -- 2048 caracteres ya que según estándares como RFC 2616 y RFC 3986, a pesar de que no haya un límiite práctico al largo de un enlace, por razones de seguridad y compatibilidad
                                                                        -- se recomienda que los enlaces no superen los 2048 caracteres
    uploadDate  DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    CONSTRAINT photo_followUp_fk FOREIGN KEY (idFollowUp) REFERENCES FollowUp (id),
    CONSTRAINT photo_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id),
    CONSTRAINT photo_photoType_fk FOREIGN KEY (idPhotoType) REFERENCES PhotoType (id)
);

CREATE TABLE IF NOT EXISTS FosterHomeStatus (
    id      INT(7) AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS FosterHome (
    idFosterHome            INT(7) PRIMARY KEY,
    idLocation              INT(7) NOT NULL,
    idFosterHomeStatus      INT(7) NOT NULL,
    maxCapacity             INT(3) NOT NULL,
    requiresFoodDonation    TINYINT(1) NOT NULL
                                CONSTRAINT fosterHome_requiresFoodDonation_chk CHECK (requiresFoodDonation IN (1,0)),
    petCount                INT(3) NOT NULL,

    CONSTRAINT fosterHome_person_fk FOREIGN KEY (idFosterHome) REFERENCES Person (id),
    CONSTRAINT fosterHome_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id),
    CONSTRAINT fosterHome_fosterHomeStatus_fk FOREIGN KEY (idFosterHomeStatus) REFERENCES FosterHomeStatus (id)
);

CREATE TABLE IF NOT EXISTS FosterHome_x_petSize (
    idFosterHome    INT(7),
    idPetSize       INT(7),

    PRIMARY KEY (idFosterHome, idPetSize),
    CONSTRAINT fosterHome_x_petSize_fosterHome_fk FOREIGN KEY (idFosterHome) REFERENCES FosterHome (idFosterHome),
    CONSTRAINT fosterHome_x_petSize_petSize_fk FOREIGN KEY (idPetSize) REFERENCES PetSize (id)
);

CREATE TABLE IF NOT EXISTS FosterHome_x_petType (
    idFosterHome    INT(7),
    idPetType      INT(7),

    PRIMARY KEY (idFosterHome, idPetType),
    CONSTRAINT fosterHome_x_petType_fosterHome_fk FOREIGN KEY (idFosterHome) REFERENCES FosterHome (idFosterHome),
    CONSTRAINT fosterHome_x_petType_petType_fk FOREIGN KEY (idPetBreed) REFERENCES PetType (id)
);

