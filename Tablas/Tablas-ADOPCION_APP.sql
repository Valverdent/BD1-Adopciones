-- ==========================================
-- == Creacion tablas esquema ADOPCION_APP ==
-- ==========================================


-- CORRER EN ESQUEMA ADOPCION_APP

-- Tablas usadas para direcciones 
CREATE TABLE Country (
    id      NUMBER(7) CONSTRAINT country_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(60) CONSTRAINT country_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Province (
    id          NUMBER(7) CONSTRAINT province_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idCountry   NUMBER(7) CONSTRAINT province_idCountry_NN NOT NULL,
    name        VARCHAR2(60) CONSTRAINT province_name_NN NOT NULL,    
    
    CONSTRAINT province_country_fk FOREIGN KEY (idCountry) 
        REFERENCES Country (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Canton (
    id          NUMBER(7) CONSTRAINT canton_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idProvince  NUMBER(7) CONSTRAINT canton_idProvince_NN NOT NULL,
    name        VARCHAR2(60) CONSTRAINT canton_name_NN NOT NULL,
    
    CONSTRAINT canton_province_fk FOREIGN KEY (idProvince) 
        REFERENCES Province (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE District (
    id      NUMBER(7) CONSTRAINT district_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idCanton    NUMBER(7) CONSTRAINT district_idCanton_NN NOT NULL,
    name    VARCHAR2(60) CONSTRAINT district_name_NN NOT NULL,
    
    CONSTRAINT district_canton_fk FOREIGN KEY (idCanton) 
        REFERENCES Canton (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Location (
    id      NUMBER(7) CONSTRAINT location_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idDistrict    NUMBER(7) CONSTRAINT location_idDistrict_NN NOT NULL,
    address    VARCHAR2(255) CONSTRAINT location_address_NN NOT NULL,
    
    CONSTRAINT location_district_fk FOREIGN KEY (idDistrict)
        REFERENCES District (id)
) TABLESPACE ADOPCION_DATA;


-- Tablas utlizadas para la table persona y sus subtablas consecuentes
CREATE TABLE Person (
    id          NUMBER(7) CONSTRAINT person_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idLocation  NUMBER(7) CONSTRAINT person_idLocation_NN NOT NULL,
    first_Name        VARCHAR2(30)  CONSTRAINT person_FirstName_NN NOT NULL,
    middle_Name       VARCHAR2(30),
    first_LastName    VARCHAR2(30)  CONSTRAINT person_FirstLastName_NN NOT NULL,
    second_LastName   VARCHAR2(30),

    CONSTRAINT person_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE BlackList (
    id          NUMBER(7) CONSTRAINT blackList_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT blackList_idPerson_NN NOT NULL,
    blackListDate DATE DEFAULT SYSDATE CONSTRAINT blackList_blackListDate_NN NOT NULL,
    blackListReason VARCHAR2(255) CONSTRAINT blackList_blackListReason_NN NOT NULL,

    CONSTRAINT blacklist_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE ContactEmail (
    id          NUMBER(7) CONSTRAINT contactEmail_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT contactEmail_idPerson_NN NOT NULL,
    email       VARCHAR2(254) CONSTRAINT contactEmail_email_NN NOT NULL, -- Limite superior de caracteres definido siguiendo estándar RFC 5321, sección 4.5.3.1 
                                        -- Cambio realizado por claridad, ya que en Modelo Lógico se define erróneamente como 'name'
    CONSTRAINT contactEmail_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE ContactNumber (
    id          NUMBER(7) CONSTRAINT contactNumber_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT contactNumber_idPerson_NN NOT NULL,
    phoneNumber       VARCHAR2(254) CONSTRAINT contactNumber_phoneNumber_NN NOT NULL, -- Limite superior de caracteres definido siguiendo norma E.164 de la ITU (Unión Internacional de Telecounicaciones)
                                        -- Cambio realizado por claridad, ya que en Modelo Lógico se define erróneamente como 'name'
    CONSTRAINT contactNumber_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
) TABLESPACE ADOPCION_DATA;


-- Tablas pertenecientes a usuario
CREATE TABLE USERSTATUS (
    id      NUMBER(7) CONSTRAINT userStatus_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT userStatus_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE "Role" (
    id      NUMBER(7) CONSTRAINT role_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT role_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE "User" (
    id          NUMBER(7) CONSTRAINT user_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT user_idPerson_NN NOT NULL
                                CONSTRAINT user_idPerson_fk REFERENCES Person (id),
    idRole      NUMBER(7) CONSTRAINT user_idRole_NN NOT NULL 
                                CONSTRAINT user_idRole_fk REFERENCES "Role" (id),
    idUserStatus    NUMBER(7) CONSTRAINT user_idUserStatus_NN NOT NULL 
                                CONSTRAINT user_idUserStatus_fk REFERENCES UserStatus (id),
    username    VARCHAR2(50) CONSTRAINT user_username_NN NOT NULL 
                                CONSTRAINT user_username_uk UNIQUE, -- UNIQUE para asegurar que no se pueda repetir un mismo username en la base de datos
    password    VARCHAR2(64 CHAR) CONSTRAINT user_password_NN NOT NULL -- 64 CHAR ya que al encriptarse la contraseña usando SHA-256, este encrptado producirá un hash de 64 caracteres, por tanto, se guarda el atributo de esta manera
) TABLESPACE ADOPCION_DATA;





-- Tablas relacionadas a la tabla Pet

CREATE TABLE PetSize (
    id      NUMBER(7) CONSTRAINT petSize_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petSize_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetColor (
    id      NUMBER(7) CONSTRAINT petColor_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petColor_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetSeverity (
    id      NUMBER(7) CONSTRAINT petSeverity_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petSeverity_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetEnergy (
    id      NUMBER(7) CONSTRAINT petEnergy_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petEnergy_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetTrainability (
    id      NUMBER(7) CONSTRAINT petTrainability_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petTrainability_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetStatus (
    id      NUMBER(7) CONSTRAINT petStatus_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petStatus_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetType (
    id      NUMBER(7) CONSTRAINT petType_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT petType_name_NN NOT NULL      
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetBreed (
    id      NUMBER(7) CONSTRAINT petBreed_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPetType NUMBER(7) CONSTRAINT petBreed_idPetType_NN NOT NULL,
    name    VARCHAR2(30) CONSTRAINT petBreed_name_NN NOT NULL,

    CONSTRAINT petBreed_petType_fk FOREIGN KEY (idPetType) REFERENCES PetType (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Veterinarian (
    id          NUMBER(7) CONSTRAINT veterinarian_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT veterinarian_idPerson_NN NOT NULL,

    CONSTRAINT veterinarian_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Pet (
    id              NUMBER(7) CONSTRAINT pet_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idLocation      NUMBER(7) CONSTRAINT pet_idLocation_NN NOT NULL,
    idPerson        NUMBER(7) CONSTRAINT pet_idPerson_NN NOT NULL,
    idPetBreed      NUMBER(7) CONSTRAINT pet_idPetBreed_NN NOT NULL,
    idPetSize       NUMBER(7) CONSTRAINT pet_idPetSize_NN NOT NULL,
    idPetColor      NUMBER(7) CONSTRAINT pet_idPetColor_NN NOT NULL,
    idPetSeverity   NUMBER(7) CONSTRAINT pet_idPetSeverity_NN NOT NULL,
    idPetEnergy     NUMBER(7) CONSTRAINT pet_idPetEnergy_NN NOT NULL,
    idPetTrainability   NUMBER(7) CONSTRAINT pet_idPetTrainability_NN NOT NULL,
    idPetStatus     NUMBER(7) CONSTRAINT pet_idPetStatus_NN NOT NULL,
    idVeterinarian  NUMBER(7) CONSTRAINT pet_idVeterinarian_NN NOT NULL,
    chipId          NUMBER(7) CONSTRAINT pet_chipId_NN NOT NULL,
    name            VARCHAR2(30) CONSTRAINT pet_name_NN NOT NULL,
    requiresSpace   NUMBER(1) CONSTRAINT pet_requiresSpace_NN NOT NULL
                                CONSTRAINT pet_requiresSpace_chk CHECK (requiresSpace IN (1,0)),
    notesDescription    VARCHAR2(255) CONSTRAINT pet_notesDescription_NN NOT NULL,
    abandonmentNotesDescription    VARCHAR2(255),
    estimatedAge    NUMBER(7),
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
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Medication (
    id      NUMBER(7) CONSTRAINT Medication_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(50) CONSTRAINT Medication_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Treatment (
    id      NUMBER(7) CONSTRAINT treatment_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT treatment_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Disease (
    id      NUMBER(7) CONSTRAINT disease_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT disease_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Medication_x_treatment (
    idMedication    NUMBER(7),
    idTreatment    NUMBER(7),
    dosage      VARCHAR2(100) CONSTRAINT Medication_x_treatment_dosage_NN NOT NULL,

    CONSTRAINT medication_x_treatment_pk PRIMARY KEY (idMedication, idTreatment) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT medication_x_treatment_medication_fk FOREIGN KEY (idMedication) REFERENCES Medication (id),
    CONSTRAINT medication_x_treatment_treatment_fk FOREIGN KEY (idTreatment) REFERENCES Treatment (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Treatment_x_disease (
    idDisease    NUMBER(7),
    idTreatment    NUMBER(7),
    timeLength      VARCHAR2(100) CONSTRAINT Treatment_x_disease_timeLength_NN NOT NULL,

    CONSTRAINT treatment_x_disease_pk PRIMARY KEY (idDisease, idTreatment) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT treatment_x_disease_treatment_fk FOREIGN KEY (idTreatment) REFERENCES Treatment (id),
    CONSTRAINT treatment_x_disease_disease_fk FOREIGN KEY (idDisease) REFERENCES Disease (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Disease_x_pet (
    idDisease    NUMBER(7),
    idPet    NUMBER(7),

    CONSTRAINT disease_x_pet_pk PRIMARY KEY (idDisease, idPet) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT disease_x_pet_disease_fk FOREIGN KEY (idDisease) REFERENCES Disease (id),
    CONSTRAINT disease_x_pet_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id)
) TABLESPACE ADOPCION_DATA;



-- Tablas utilizadas para donaciones
CREATE TABLE DonationType (
    id      NUMBER(7) CONSTRAINT donationType_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT donationType_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE CurrencyType (
    id      NUMBER(7) CONSTRAINT currencyType_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT currencyType_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE AnimalWelfareAssociation (
    id          NUMBER(7) CONSTRAINT animalWelfareAssociation_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idLocation  NUMBER(7) CONSTRAINT animalWelfareAssociation_idLocation_NN NOT NULL,
    name        VARCHAR2(60) CONSTRAINT animalWelfareAssociation_name_NN NOT NULL,

    CONSTRAINT animalWelfareAssociation_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Reward (
    id      NUMBER(7) CONSTRAINT reward_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPet   NUMBER(7) CONSTRAINT reward_idPet_NN NOT NULL,
    idCurrencyType   NUMBER(7) CONSTRAINT reward_idCurrencyType_NN NOT NULL,
    amount  NUMBER(9) CONSTRAINT reward_amount_NN NOT NULL,

    CONSTRAINT reward_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id),
    CONSTRAINT reward_currencyType_fk FOREIGN KEY (idCurrencyType) REFERENCES CurrencyType (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Donation (
    id              NUMBER(7) CONSTRAINT donation_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson        NUMBER(7) CONSTRAINT donation_idPerson_NN NOT NULL,
    idDonationType  NUMBER(7) CONSTRAINT donation_idDonationType_NN NOT NULL,
    idCurrencyType  NUMBER(7) CONSTRAINT donation_idCurrencyType_NN NOT NULL,
    idReward        NUMBER(7) CONSTRAINT donation_idReward_NN NOT NULL,
    donationDate    DATE DEFAULT SYSDATE CONSTRAINT donation_donationDate_NN NOT NULL,

    CONSTRAINT donation_idPerson FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT donation_idDonationType FOREIGN KEY (idDonationType) REFERENCES DonationType (id),
    CONSTRAINT donation_idCurrencyType FOREIGN KEY (idCurrencyType) REFERENCES CurrencyType (id),
    CONSTRAINT donation_idReward FOREIGN KEY (idReward) REFERENCES Reward (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE DonationDetail (
    idAnimalWelfareAssociation NUMBER(7),
    idDonation  NUMBER(7),
    amount      NUMBER(9) CONSTRAINT donationDetail_amount_NN NOT NULL,
    percentage  NUMBER(3) CONSTRAINT donationDetail_percentage_NN NOT NULL,

    CONSTRAINT donationDetail_pk PRIMARY KEY (idAnimalWelfareAssociation, idDonation) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT donationDetail_animalWelfareAssociation_fk FOREIGN KEY (idAnimalWelfareAssociation) REFERENCES AnimalWelfareAssociation (id),
    CONSTRAINT donationDetail_donation_fk FOREIGN KEY (idDonation) REFERENCES Donation (id)
) TABLESPACE ADOPCION_DATA;



-- Tablas usadas para el proceso de adopcion
CREATE TABLE ExerciseTime (
    id      NUMBER(7) CONSTRAINT exerciseTime_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    value   VARCHAR2(30) CONSTRAINT exerciseTime_value_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE HouseType (
    id      NUMBER(7) CONSTRAINT houseType_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT houseType_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE House (
    id              NUMBER(7) CONSTRAINT house_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idHouseType     NUMBER(7) CONSTRAINT house_idHouseType_NN NOT NULL,
    hasYard         NUMBER(1) CONSTRAINT house_hasYard_NN NOT NULL
                                CONSTRAINT house_hasYard_chk CHECK (hasYard IN (1,0)),

    CONSTRAINT house_houseType_fk FOREIGN KEY (idHouseType) REFERENCES HouseType (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Adopter (
    idAdopter       NUMBER(7) CONSTRAINT adopter_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idHouse         NUMBER(7) CONSTRAINT adopter_idHouse_NN NOT NULL,
    idExerciseTime  NUMBER(7) CONSTRAINT adopter_idExerciseTime_NN NOT NULL,    

    CONSTRAINT adopter_person_fk FOREIGN KEY (idAdopter) REFERENCES Person (id),
    CONSTRAINT adopter_house_fk FOREIGN KEY (idHouse) REFERENCES House (id),
    CONSTRAINT adopter_exerciseTime_fk FOREIGN KEY (idExerciseTime) REFERENCES ExerciseTime (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE Adoption (
    id          NUMBER(7) CONSTRAINT adoption_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPerson    NUMBER(7) CONSTRAINT adoption_idPerson_NN NOT NULL,
    idAdopter   NUMBER(7) CONSTRAINT adoption_idAdopter_NN NOT NULL,
    idPet       NUMBER(7) CONSTRAINT adoption_idPet_NN NOT NULL,
    adoptionDate DATE DEFAULT SYSDATE CONSTRAINT adoption_adoptionDate_NN NOT NULL,

    CONSTRAINT adoption_person_fk FOREIGN KEY (idPerson) REFERENCES Person (id),
    CONSTRAINT adoption_adopter_fk FOREIGN KEY (idAdopter) REFERENCES Adopter (idAdopter),
    CONSTRAINT adoption_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE FollowUp (
    id          NUMBER(7) CONSTRAINT followUp_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idAdoption  NUMBER(7) CONSTRAINT followUp_idAdoption_NN NOT NULL,
    comments    VARCHAR2(255) CONSTRAINT followUp_comments_NN NOT NULL,
    followUpDate DATE DEFAULT SYSDATE CONSTRAINT followUp_followUpDate_NN NOT NULL,

    CONSTRAINT followUp_adoption_fk FOREIGN KEY (idAdoption) REFERENCES Adoption (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PetOwnerRating (
    id          NUMBER(7) CONSTRAINT petOwnerRating_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idAdoption  NUMBER(7) CONSTRAINT petOwnerRating_idAdoption_NN NOT NULL,
    rating      NUMBER(2) CONSTRAINT petOwnerRating_rating_NN NOT NULL,
    notes       VARCHAR2(255) CONSTRAINT petOwnerRating_notes_NN NOT NULL,

    CONSTRAINT petOwnerRating_adoption_fk FOREIGN KEY (idAdoption) REFERENCES Adoption (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE OtherPet (
    id          NUMBER(7) CONSTRAINT otherPet_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idPetBreed  NUMBER(7) CONSTRAINT otherPet_idPetBreed_NN NOT NULL,
    idAdopter   NUMBER(7) CONSTRAINT otherPet_idAdopter_NN NOT NULL,

    CONSTRAINT otherPet_petBreed_fk FOREIGN KEY (idPetBreed) REFERENCES PetBreed (id),
    CONSTRAINT otherPet_adopter_fk FOREIGN KEY (idAdopter) REFERENCES Adopter (idAdopter)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE PhotoType (
    id      NUMBER(7) CONSTRAINT photoType_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_DOCS_IDX,
    name    VARCHAR2(30) CONSTRAINT photoType_name_NN NOT NULL
) TABLESPACE ADOPCION_DOCS_DATA;

CREATE TABLE Photo (
    id          NUMBER(7) CONSTRAINT photo_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_DOCS_IDX,
    idFollowUp  NUMBER(7) CONSTRAINT photo_idFollowUp_NN NOT NULL,
    idPet       NUMBER(7) CONSTRAINT photo_idPet_NN NOT NULL,
    idPhotoType NUMBER(7) CONSTRAINT photo_idPhotoType_NN NOT NULL,
    photoURL    VARCHAR2(2048)  CONSTRAINT photo_photoUrl_NN NOT NULL,  -- 2048 caracteres ya que según estándares como RFC 2616 y RFC 3986, a pesar de que no haya un límiite práctico al largo de un enlace, por razones de seguridad y compatibilidad
                                                                        -- se recomienda que los enlaces no superen los 2048 caracteres
    uploadDate  DATE DEFAULT SYSDATE CONSTRAINT photo_uploadDate_NN NOT NULL,

    CONSTRAINT photo_followUp_fk FOREIGN KEY (idFollowUp) REFERENCES FollowUp (id),
    CONSTRAINT photo_pet_fk FOREIGN KEY (idPet) REFERENCES Pet (id),
    CONSTRAINT photo_photoType_fk FOREIGN KEY (idPhotoType) REFERENCES PhotoType (id)
) TABLESPACE ADOPCION_DOCS_DATA;

CREATE TABLE FosterHomeStatus (
    id      NUMBER(7) CONSTRAINT fosterHomeStatus_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name    VARCHAR2(30) CONSTRAINT fosterHomeStatus_name_NN NOT NULL
) TABLESPACE ADOPCION_DATA;

CREATE TABLE FosterHome (
    idFosterHome            NUMBER(7) CONSTRAINT fosterHome_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    idLocation              NUMBER(7) CONSTRAINT fosterHome_idLocation_NN NOT NULL,
    idFosterHomeStatus      NUMBER(7) CONSTRAINT fosterHome_idFosterHomeStatus_NN NOT NULL,
    maxCapacity             NUMBER(3) CONSTRAINT fosterHome_maxCapacity_NN NOT NULL,
    requiresFoodDonation    NUMBER(1) CONSTRAINT fosterHome_requiresFoodDonation_NN NOT NULL
                                CONSTRAINT fosterHome_requiresFoodDonation_chk CHECK (requiresFoodDonation IN (1,0)),
    petCount                NUMBER(3) CONSTRAINT fosterHome_petCount_NN NOT NULL,

    CONSTRAINT fosterHome_person_fk FOREIGN KEY (idFosterHome) REFERENCES Person (id),
    CONSTRAINT fosterHome_location_fk FOREIGN KEY (idLocation) REFERENCES Location (id),
    CONSTRAINT fosterHome_fosterHomeStatus_fk FOREIGN KEY (idFosterHomeStatus) REFERENCES FosterHomeStatus (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE FosterHome_x_petSize (
    idFosterHome    NUMBER(7),
    idPetSize       NUMBER(7),

    CONSTRAINT fosterHome_x_petSize_pk PRIMARY KEY (idFosterHome, idPetSize) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT fosterHome_x_petSize_fosterHome_fk FOREIGN KEY (idFosterHome) REFERENCES FosterHome (idFosterHome),
    CONSTRAINT fosterHome_x_petSize_petSize_fk FOREIGN KEY (idPetSize) REFERENCES PetSize (id)
) TABLESPACE ADOPCION_DATA;

CREATE TABLE FosterHome_x_petBreed (
    idFosterHome    NUMBER(7),
    idPetBreed      NUMBER(7),

    CONSTRAINT fosterHome_x_petBreed_pk PRIMARY KEY (idFosterHome, idPetBreed) USING INDEX TABLESPACE ADOPCION_IDX,
    CONSTRAINT fosterHome_x_petBreed_fosterHome_fk FOREIGN KEY (idFosterHome) REFERENCES fosterHome (idFosterHome),
    CONSTRAINT fosterHome_x_petBreed_petBreed_fk FOREIGN KEY (idPetBreed) REFERENCES PetBreed (id)
) TABLESPACE ADOPCION_DATA;

