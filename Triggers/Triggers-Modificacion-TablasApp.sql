-- CORRIDO DESDE ADOPCION_APP


-- Tablas relacionadas a person
ALTER TABLE UserStatus ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT userStatus_creationDate_NN NOT NULL);
ALTER TABLE UserStatus ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT userStatus_createdBy_NN NOT NULL);
ALTER TABLE UserStatus ADD (updatedDate DATE);
ALTER TABLE UserStatus ADD (updatedBy VARCHAR2(30));

ALTER TABLE "Role" ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT role_creationDate_NN NOT NULL);
ALTER TABLE "Role" ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT role_createdBy_NN NOT NULL);
ALTER TABLE "Role" ADD (updatedDate DATE);
ALTER TABLE "Role" ADD (updatedBy VARCHAR2(30));

ALTER TABLE "User" ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT user_creationDate_NN NOT NULL);
ALTER TABLE "User" ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT user_createdBy_NN NOT NULL);
ALTER TABLE "User" ADD (updatedDate DATE);
ALTER TABLE "User" ADD (updatedBy VARCHAR2(30));

ALTER TABLE BlackList ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT blackList_creationDate_NN NOT NULL);
ALTER TABLE BlackList ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT blackList_createdBy_NN NOT NULL);
ALTER TABLE BlackList ADD (updatedDate DATE);
ALTER TABLE BlackList ADD (updatedBy VARCHAR2(30));

ALTER TABLE ContactEmail ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT contactEmail_creationDate_NN NOT NULL);
ALTER TABLE ContactEmail ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT contactEmail_createdBy_NN NOT NULL);
ALTER TABLE ContactEmail ADD (updatedDate DATE);
ALTER TABLE ContactEmail ADD (updatedBy VARCHAR2(30));

ALTER TABLE ContactNumber ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT contactNumber_creationDate_NN NOT NULL);
ALTER TABLE ContactNumber ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT contactNumber_createdBy_NN NOT NULL);
ALTER TABLE ContactNumber ADD (updatedDate DATE);
ALTER TABLE ContactNumber ADD (updatedBy VARCHAR2(30));

ALTER TABLE Person ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT person_creationDate_NN NOT NULL);
ALTER TABLE Person ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT person_createdBy_NN NOT NULL);
ALTER TABLE Person ADD (updatedDate DATE);
ALTER TABLE Person ADD (updatedBy VARCHAR2(30));

-- Tablas relacionadas a las direcciones
ALTER TABLE Country ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT country_creationDate_NN NOT NULL);
ALTER TABLE Country ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT country_createdBy_NN NOT NULL);
ALTER TABLE Country ADD (updatedDate DATE);
ALTER TABLE Country ADD (updatedBy VARCHAR2(30));

ALTER TABLE Province ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT province_creationDate_NN NOT NULL);
ALTER TABLE Province ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT province_createdBy_NN NOT NULL);
ALTER TABLE Province ADD (updatedDate DATE);
ALTER TABLE Province ADD (updatedBy VARCHAR2(30));

ALTER TABLE Canton ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT canton_creationDate_NN NOT NULL);
ALTER TABLE Canton ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT canton_createdBy_NN NOT NULL);
ALTER TABLE Canton ADD (updatedDate DATE);
ALTER TABLE Canton ADD (updatedBy VARCHAR2(30));

ALTER TABLE Location ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT location_creationDate_NN NOT NULL);
ALTER TABLE Location ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT location_createdBy_NN NOT NULL);
ALTER TABLE Location ADD (updatedDate DATE);
ALTER TABLE Location ADD (updatedBy VARCHAR2(30));

ALTER TABLE District ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT district_creationDate_NN NOT NULL);
ALTER TABLE District ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT district_createdBy_NN NOT NULL);
ALTER TABLE District ADD (updatedDate DATE);
ALTER TABLE District ADD (updatedBy VARCHAR2(30));

-- Tablas relacionadas a las donaciones

ALTER TABLE DonationType ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT donationType_creationDate_NN NOT NULL);
ALTER TABLE DonationType ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT donationType_createdBy_NN NOT NULL);
ALTER TABLE DonationType ADD (updatedDate DATE);
ALTER TABLE DonationType ADD (updatedBy VARCHAR2(30));

ALTER TABLE Donation ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT donation_creationDate_NN NOT NULL);
ALTER TABLE Donation ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT donation_createdBy_NN NOT NULL);
ALTER TABLE Donation ADD (updatedDate DATE);
ALTER TABLE Donation ADD (updatedBy VARCHAR2(30));

ALTER TABLE CurrencyType ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT currencyType_creationDate_NN NOT NULL);
ALTER TABLE CurrencyType ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT currencyType_createdBy_NN NOT NULL);
ALTER TABLE CurrencyType ADD (updatedDate DATE);
ALTER TABLE CurrencyType ADD (updatedBy VARCHAR2(30));

ALTER TABLE DonationDetail ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT donationDetail_creationDate_NN NOT NULL);
ALTER TABLE DonationDetail ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT donationDetail_createdBy_NN NOT NULL);
ALTER TABLE DonationDetail ADD (updatedDate DATE);
ALTER TABLE DonationDetail ADD (updatedBy VARCHAR2(30));

ALTER TABLE AnimalWelfareAssociation ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT animalWelfareAssociation_creationDate_NN NOT NULL);
ALTER TABLE AnimalWelfareAssociation ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT animalWelfareAssociation_createdBy_NN NOT NULL);
ALTER TABLE AnimalWelfareAssociation ADD (updatedDate DATE);
ALTER TABLE AnimalWelfareAssociation ADD (updatedBy VARCHAR2(30));

-- Tablas relacionadas a la FosterHome

ALTER TABLE FosterHome ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT fosterHome_creationDate_NN NOT NULL);
ALTER TABLE FosterHome ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT fosterHome_createdBy_NN NOT NULL);
ALTER TABLE FosterHome ADD (updatedDate DATE);
ALTER TABLE FosterHome ADD (updatedBy VARCHAR2(30));

ALTER TABLE FosterHomeStatus ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT fosterHomeStatus_creationDate_NN NOT NULL);
ALTER TABLE FosterHomeStatus ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT fosterHomeStatus_createdBy_NN NOT NULL);
ALTER TABLE FosterHomeStatus ADD (updatedDate DATE);
ALTER TABLE FosterHomeStatus ADD (updatedBy VARCHAR2(30));

ALTER TABLE HouseType ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT houseType_creationDate_NN NOT NULL);
ALTER TABLE HouseType ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT houseType_createdBy_NN NOT NULL);
ALTER TABLE HouseType ADD (updatedDate DATE);
ALTER TABLE HouseType ADD (updatedBy VARCHAR2(30));

ALTER TABLE House ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT house_creationDate_NN NOT NULL);
ALTER TABLE House ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT house_createdBy_NN NOT NULL);
ALTER TABLE House ADD (updatedDate DATE);
ALTER TABLE House ADD (updatedBy VARCHAR2(30));

ALTER TABLE OtherPet ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT otherPet_creationDate_NN NOT NULL);
ALTER TABLE OtherPet ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT otherPet_createdBy_NN NOT NULL);
ALTER TABLE OtherPet ADD (updatedDate DATE);
ALTER TABLE OtherPet ADD (updatedBy VARCHAR2(30));

ALTER TABLE FosterHome_x_petSize ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT fosterHome_x_petSize_creationDate_NN NOT NULL);
ALTER TABLE FosterHome_x_petSize ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT fosterHome_x_petSize_createdBy_NN NOT NULL);
ALTER TABLE FosterHome_x_petSize ADD (updatedDate DATE);
ALTER TABLE FosterHome_x_petSize ADD (updatedBy VARCHAR2(30));

ALTER TABLE FosterHome_x_petBreed ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT fosterHome_x_petBreed_creationDate_NN NOT NULL);
ALTER TABLE FosterHome_x_petBreed ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT fosterHome_x_petBreed_createdBy_NN NOT NULL);
ALTER TABLE FosterHome_x_petBreed ADD (updatedDate DATE);
ALTER TABLE FosterHome_x_petBreed ADD (updatedBy VARCHAR2(30));


-- Tablas relacionadas con el proceso de adopción

ALTER TABLE Adopter ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT adopter_creationDate_NN NOT NULL);
ALTER TABLE Adopter ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT adopter_createdBy_NN NOT NULL);
ALTER TABLE Adopter ADD (updatedDate DATE);
ALTER TABLE Adopter ADD (updatedBy VARCHAR2(30));

ALTER TABLE Adoption ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT adoption_creationDate_NN NOT NULL);
ALTER TABLE Adoption ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT adoption_createdBy_NN NOT NULL);
ALTER TABLE Adoption ADD (updatedDate DATE);
ALTER TABLE Adoption ADD (updatedBy VARCHAR2(30));

ALTER TABLE ExerciseTime ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT exerciseTime_creationDate_NN NOT NULL);
ALTER TABLE ExerciseTime ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT exerciseTime_createdBy_NN NOT NULL);
ALTER TABLE ExerciseTime ADD (updatedDate DATE);
ALTER TABLE ExerciseTime ADD (updatedBy VARCHAR2(30));

ALTER TABLE FollowUp ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT followUp_creationDate_NN NOT NULL);
ALTER TABLE FollowUp ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT followUp_createdBy_NN NOT NULL);
ALTER TABLE FollowUp ADD (updatedDate DATE);
ALTER TABLE FollowUp ADD (updatedBy VARCHAR2(30));

ALTER TABLE Photo ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT photo_creationDate_NN NOT NULL);
ALTER TABLE Photo ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT photo_createdBy_NN NOT NULL);
ALTER TABLE Photo ADD (updatedDate DATE);
ALTER TABLE Photo ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetOwnerRating ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petOwnerRating_creationDate_NN NOT NULL);
ALTER TABLE PetOwnerRating ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petOwnerRating_createdBy_NN NOT NULL);
ALTER TABLE PetOwnerRating ADD (updatedDate DATE);
ALTER TABLE PetOwnerRating ADD (updatedBy VARCHAR2(30));


-- Tablas relacionadas con la mascota

ALTER TABLE Veterinarian ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT veterinarian_creationDate_NN NOT NULL);
ALTER TABLE Veterinarian ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT veterinarian_createdBy_NN NOT NULL);
ALTER TABLE Veterinarian ADD (updatedDate DATE);
ALTER TABLE Veterinarian ADD (updatedBy VARCHAR2(30));

ALTER TABLE Disease ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT disease_creationDate_NN NOT NULL);
ALTER TABLE Disease ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT disease_createdBy_NN NOT NULL);
ALTER TABLE Disease ADD (updatedDate DATE);
ALTER TABLE Disease ADD (updatedBy VARCHAR2(30));

ALTER TABLE Treatment ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT treatment_creationDate_NN NOT NULL);
ALTER TABLE Treatment ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT treatment_createdBy_NN NOT NULL);
ALTER TABLE Treatment ADD (updatedDate DATE);
ALTER TABLE Treatment ADD (updatedBy VARCHAR2(30));

ALTER TABLE Medication ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT medication_creationDate_NN NOT NULL);
ALTER TABLE Medication ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT medication_createdBy_NN NOT NULL);
ALTER TABLE Medication ADD (updatedDate DATE);
ALTER TABLE Medication ADD (updatedBy VARCHAR2(30));

ALTER TABLE Reward ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT reward_creationDate_NN NOT NULL);
ALTER TABLE Reward ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT reward_createdBy_NN NOT NULL);
ALTER TABLE Reward ADD (updatedDate DATE);
ALTER TABLE Reward ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetBreed ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petBreed_creationDate_NN NOT NULL);
ALTER TABLE PetBreed ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petBreed_createdBy_NN NOT NULL);
ALTER TABLE PetBreed ADD (updatedDate DATE);
ALTER TABLE PetBreed ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetType ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petType_creationDate_NN NOT NULL);
ALTER TABLE PetType ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petType_createdBy_NN NOT NULL);
ALTER TABLE PetType ADD (updatedDate DATE);
ALTER TABLE PetType ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetSize ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petSize_creationDate_NN NOT NULL);
ALTER TABLE PetSize ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petSize_createdBy_NN NOT NULL);
ALTER TABLE PetSize ADD (updatedDate DATE);
ALTER TABLE PetSize ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetColor ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petColor_creationDate_NN NOT NULL);
ALTER TABLE PetColor ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petColor_createdBy_NN NOT NULL);
ALTER TABLE PetColor ADD (updatedDate DATE);
ALTER TABLE PetColor ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetSeverity ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petSeverity_creationDate_NN NOT NULL);
ALTER TABLE PetSeverity ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petSeverity_createdBy_NN NOT NULL);
ALTER TABLE PetSeverity ADD (updatedDate DATE);
ALTER TABLE PetSeverity ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetTrainability ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petTrainability_creationDate_NN NOT NULL);
ALTER TABLE PetTrainability ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petTrainability_createdBy_NN NOT NULL);
ALTER TABLE PetTrainability ADD (updatedDate DATE);
ALTER TABLE PetTrainability ADD (updatedBy VARCHAR2(30));

ALTER TABLE PetStatus ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT petStatus_creationDate_NN NOT NULL);
ALTER TABLE PetStatus ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT petStatus_createdBy_NN NOT NULL);
ALTER TABLE PetStatus ADD (updatedDate DATE);
ALTER TABLE PetStatus ADD (updatedBy VARCHAR2(30));

ALTER TABLE Pet ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT pet_creationDate_NN NOT NULL);
ALTER TABLE Pet ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT pet_createdBy_NN NOT NULL);
ALTER TABLE Pet ADD (updatedDate DATE);
ALTER TABLE Pet ADD (updatedBy VARCHAR2(30));

ALTER TABLE Disease_x_pet ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT disease_x_pet_creationDate_NN NOT NULL);
ALTER TABLE Disease_x_pet ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT disease_x_pet_createdBy_NN NOT NULL);
ALTER TABLE Disease_x_pet ADD (updatedDate DATE);
ALTER TABLE Disease_x_pet ADD (updatedBy VARCHAR2(30));

ALTER TABLE Treatment_x_disease ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT treatment_x_disease_creationDate_NN NOT NULL);
ALTER TABLE Treatment_x_disease ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT treatment_x_disease_createdBy_NN NOT NULL);
ALTER TABLE Treatment_x_disease ADD (updatedDate DATE);
ALTER TABLE Treatment_x_disease ADD (updatedBy VARCHAR2(30));

ALTER TABLE Medication_x_treatment ADD (creationDate DATE DEFAULT SYSDATE CONSTRAINT medication_x_treatment_creationDate_NN NOT NULL);
ALTER TABLE Medication_x_treatment ADD (createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT medication_x_treatment_createdBy_NN NOT NULL);
ALTER TABLE Medication_x_treatment ADD (updatedDate DATE);
ALTER TABLE Medication_x_treatment ADD (updatedBy VARCHAR2(30));

CREATE TABLE Parameter (
    id          NUMBER(7) CONSTRAINT parameter_pk PRIMARY KEY USING INDEX TABLESPACE ADOPCION_IDX,
    name        VARCHAR2(50) CONSTRAINT parameter_name_NN NOT NULL,
    description VARCHAR2(255) NOT NULL,
    value    VARCHAR2(255),
    creationDate DATE DEFAULT SYSDATE CONSTRAINT parameter_creationDate_NN NOT NULL,
    createdBy VARCHAR2(30) DEFAULT 'ADOPCION_APP' CONSTRAINT parameter_createdBy_NN NOT NULL,
    updatedDate DATE,
    updatedBy VARCHAR2(30)
) TABLESPACE ADOPCION_DATA;

COMMIT;
