USE ADOPCION_APP;

-- ================================================
-- ==== Triggers relacionados al usuario ====
-- ================================================
-- UserStatus
DROP TRIGGER IF EXISTS beforeInsertUserStatus;
DELIMITER //
CREATE TRIGGER beforeInsertUserStatus
    BEFORE INSERT ON UserStatus
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateUserStatus;
DELIMITER //
CREATE TRIGGER beforeUpdateUserStatus
    BEFORE UPDATE ON UserStatus
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed status name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteUserStatus;
DELIMITER //
CREATE TRIGGER beforeDeleteUserStatus
    BEFORE DELETE ON UserStatus
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Role
DROP TRIGGER IF EXISTS beforeInsertRole;
DELIMITER //
CREATE TRIGGER beforeInsertRole
    BEFORE INSERT ON `Role`
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateRole;
DELIMITER //
CREATE TRIGGER beforeUpdateRole
    BEFORE UPDATE ON `Role`
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed role name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteRole;
DELIMITER //
CREATE TRIGGER beforeDeleteRole
    BEFORE DELETE ON `Role`
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- User
DROP TRIGGER IF EXISTS beforeInsertUser;
DELIMITER //
CREATE TRIGGER beforeInsertUser
    BEFORE INSERT ON `User`
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateUser;
DELIMITER //
CREATE TRIGGER beforeUpdateUser
    BEFORE UPDATE ON `User`
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated person', CURRENT_USER());
    END IF;
    IF OLD.idRole != NEW.idRole THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idRole', CAST(OLD.idRole AS CHAR), CAST(NEW.idRole AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated role', CURRENT_USER());
    END IF;
    IF OLD.idUserStatus != NEW.idUserStatus THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idUserStatus', CAST(OLD.idUserStatus AS CHAR), CAST(NEW.idUserStatus AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated status', CURRENT_USER());
    END IF;
    IF OLD.username != NEW.username THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'username', OLD.username, NEW.username, CAST(NEW.id AS CHAR), 'Changed username', CURRENT_USER());
    END IF;
    IF OLD.password != NEW.password THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'password', OLD.password, NEW.password, CAST(NEW.id AS CHAR), 'Changed password', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteUser;
DELIMITER //
CREATE TRIGGER beforeDeleteUser
    BEFORE DELETE ON `User`
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- BlackList
DROP TRIGGER IF EXISTS beforeInsertBlackList;
DELIMITER //
CREATE TRIGGER beforeInsertBlackList
    BEFORE INSERT ON BlackList
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateBlackList;
DELIMITER //
CREATE TRIGGER beforeUpdateBlackList
    BEFORE UPDATE ON BlackList
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated person', CURRENT_USER());
    END IF;
    IF OLD.blackListDate != NEW.blackListDate THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', 'blackListDate', CAST(OLD.blackListDate AS CHAR), CAST(NEW.blackListDate AS CHAR), CAST(NEW.id AS CHAR), 'Changed date when blacklist record was created', CURRENT_USER());
    END IF;
    IF OLD.blackListReason != NEW.blackListReason THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', 'blackListReason', OLD.blackListReason, NEW.blackListReason, CAST(NEW.id AS CHAR), 'Changed reason why blacklist record was created', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteBlackList;
DELIMITER //
CREATE TRIGGER beforeDeleteBlackList
    BEFORE DELETE ON BlackList
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Person
DROP TRIGGER IF EXISTS beforeInsertPerson;
DELIMITER //
CREATE TRIGGER beforeInsertPerson
    BEFORE INSERT ON Person
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePerson;
DELIMITER //
CREATE TRIGGER beforeUpdatePerson
    BEFORE UPDATE ON Person
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', 'idLocation', CAST(OLD.idLocation AS CHAR), CAST(NEW.idLocation AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated location', CURRENT_USER());
    END IF;
    IF OLD.firstName != NEW.firstName THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', 'firstName', OLD.firstName, NEW.firstName, CAST(NEW.id AS CHAR), 'Changed first name info', CURRENT_USER());
    END IF;
    IF OLD.middleName != NEW.middleName THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', 'middleName', OLD.middleName, NEW.middleName, CAST(NEW.id AS CHAR), 'Changed middle name info', CURRENT_USER());
    END IF;
    IF OLD.firstLastName != NEW.firstLastName THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', 'firstLastName', OLD.firstLastName, NEW.firstLastName, CAST(NEW.id AS CHAR), 'Changed first last name info', CURRENT_USER());
    END IF;
    IF OLD.secondLastName != NEW.secondLastName THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', 'secondLastName', OLD.secondLastName, NEW.secondLastName, CAST(NEW.id AS CHAR), 'Changed second last name info', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePerson;
DELIMITER //
CREATE TRIGGER beforeDeletePerson
    BEFORE DELETE ON Person
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ContactEmail
DROP TRIGGER IF EXISTS beforeInsertContactEmail;
DELIMITER //
CREATE TRIGGER beforeInsertContactEmail
    BEFORE INSERT ON ContactEmail
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateContactEmail;
DELIMITER //
CREATE TRIGGER beforeUpdateContactEmail
    BEFORE UPDATE ON ContactEmail
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.email != NEW.email THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', 'email', OLD.email, NEW.email, CAST(NEW.id AS CHAR), 'Changed email address', CURRENT_USER());
    END IF;
    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated person', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteContactEmail;
DELIMITER //
CREATE TRIGGER beforeDeleteContactEmail
    BEFORE DELETE ON ContactEmail
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ContactNumber
DROP TRIGGER IF EXISTS beforeInsertContactNumber;
DELIMITER //
CREATE TRIGGER beforeInsertContactNumber
    BEFORE INSERT ON ContactNumber
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateContactNumber;
DELIMITER //
CREATE TRIGGER beforeUpdateContactNumber
    BEFORE UPDATE ON ContactNumber
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.phoneNumber != NEW.phoneNumber THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', 'phoneNumber', OLD.phoneNumber, NEW.phoneNumber, CAST(NEW.id AS CHAR), 'Changed phone number', CURRENT_USER());
    END IF;
    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated person', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteContactNumber;
DELIMITER //
CREATE TRIGGER beforeDeleteContactNumber
    BEFORE DELETE ON ContactNumber
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Country
DROP TRIGGER IF EXISTS beforeInsertCountry;
DELIMITER //
CREATE TRIGGER beforeInsertCountry
    BEFORE INSERT ON Country
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Country', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateCountry;
DELIMITER //
CREATE TRIGGER beforeUpdateCountry
    BEFORE UPDATE ON Country
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Country', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed country name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteCountry;
DELIMITER //
CREATE TRIGGER beforeDeleteCountry
    BEFORE DELETE ON Country
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Country', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Province
DROP TRIGGER IF EXISTS beforeInsertProvince;
DELIMITER //
CREATE TRIGGER beforeInsertProvince
    BEFORE INSERT ON Province
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateProvince;
DELIMITER //
CREATE TRIGGER beforeUpdateProvince
    BEFORE UPDATE ON Province
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed province name', CURRENT_USER());
    END IF;
    IF OLD.idCountry != NEW.idCountry THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', 'idCountry', CAST(OLD.idCountry AS CHAR), CAST(NEW.idCountry AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated country', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteProvince;
DELIMITER //
CREATE TRIGGER beforeDeleteProvince
    BEFORE DELETE ON Province
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Canton
DROP TRIGGER IF EXISTS beforeInsertCanton;
DELIMITER //
CREATE TRIGGER beforeInsertCanton
    BEFORE INSERT ON Canton
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateCanton;
DELIMITER //
CREATE TRIGGER beforeUpdateCanton
    BEFORE UPDATE ON Canton
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed Canton name', CURRENT_USER());
    END IF;
    IF OLD.idProvince != NEW.idProvince THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', 'idProvince', CAST(OLD.idProvince AS CHAR), CAST(NEW.idProvince AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated province', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteCanton;
DELIMITER //
CREATE TRIGGER beforeDeleteCanton
    BEFORE DELETE ON Canton
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- District
DROP TRIGGER IF EXISTS beforeInsertDistrict;
DELIMITER //
CREATE TRIGGER beforeInsertDistrict
    BEFORE INSERT ON District
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDistrict;
DELIMITER //
CREATE TRIGGER beforeUpdateDistrict
    BEFORE UPDATE ON District
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed District name', CURRENT_USER());
    END IF;
    IF OLD.idCanton != NEW.idCanton THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', 'idCanton', CAST(OLD.idCanton AS CHAR), CAST(NEW.idCanton AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated canton', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDistrict;
DELIMITER //
CREATE TRIGGER beforeDeleteDistrict
    BEFORE DELETE ON District
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Location
DROP TRIGGER IF EXISTS beforeInsertLocation;
DELIMITER //
CREATE TRIGGER beforeInsertLocation
    BEFORE INSERT ON Location
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateLocation;
DELIMITER //
CREATE TRIGGER beforeUpdateLocation
    BEFORE UPDATE ON Location
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.address != NEW.address THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', 'address', OLD.address, NEW.address, CAST(NEW.id AS CHAR), 'Changed Location address', CURRENT_USER());
    END IF;
    IF OLD.idDistrict != NEW.idDistrict THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', 'idDistrict', CAST(OLD.idDistrict AS CHAR), CAST(NEW.idDistrict AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated district', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteLocation;
DELIMITER //
CREATE TRIGGER beforeDeleteLocation
    BEFORE DELETE ON Location
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ======================================================================
-- ==== Triggers para tablas relacionadas a AnimalWelfareAssociation ====
-- ======================================================================
-- DonationType
DROP TRIGGER IF EXISTS beforeInsertDonationType;
DELIMITER //
CREATE TRIGGER beforeInsertDonationType
    BEFORE INSERT ON DonationType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationType', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDonationType;
DELIMITER //
CREATE TRIGGER beforeUpdateDonationType
    BEFORE UPDATE ON DonationType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationType', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed donation type name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDonationType;
DELIMITER //
CREATE TRIGGER beforeDeleteDonationType
    BEFORE DELETE ON DonationType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationType', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- CurrencyType
DROP TRIGGER IF EXISTS beforeInsertCurrencyType;
DELIMITER //
CREATE TRIGGER beforeInsertCurrencyType
    BEFORE INSERT ON CurrencyType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'CurrencyType', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateCurrencyType;
DELIMITER //
CREATE TRIGGER beforeUpdateCurrencyType
    BEFORE UPDATE ON CurrencyType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'CurrencyType', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed currency type name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteCurrencyType;
DELIMITER //
CREATE TRIGGER beforeDeleteCurrencyType
    BEFORE DELETE ON CurrencyType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'CurrencyType', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- AnimalWelfareAssociation
DROP TRIGGER IF EXISTS beforeInsertAnimalWelfareAssociation;
DELIMITER //
CREATE TRIGGER beforeInsertAnimalWelfareAssociation
    BEFORE INSERT ON AnimalWelfareAssociation
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateAnimalWelfareAssociation;
DELIMITER //
CREATE TRIGGER beforeUpdateAnimalWelfareAssociation
    BEFORE UPDATE ON AnimalWelfareAssociation
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed animal welfare association name', CURRENT_USER());
    END IF;
    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', 'idLocation', CAST(OLD.idLocation AS CHAR), CAST(NEW.idLocation AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated location', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteAnimalWelfareAssociation;
DELIMITER //
CREATE TRIGGER beforeDeleteAnimalWelfareAssociation
    BEFORE DELETE ON AnimalWelfareAssociation
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- DonationDetail
DROP TRIGGER IF EXISTS beforeInsertDonationDetail;
DELIMITER //
CREATE TRIGGER beforeInsertDonationDetail
    BEFORE INSERT ON DonationDetail
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL, CONCAT(CAST(NEW.idAnimalWelfareAssociation AS CHAR), '-', CAST(NEW.idDonation AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDonationDetail;
DELIMITER //
CREATE TRIGGER beforeUpdateDonationDetail
    BEFORE UPDATE ON DonationDetail
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.amount != NEW.amount THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationDetail', 'amount', CAST(OLD.amount AS CHAR), CAST(NEW.amount AS CHAR), CONCAT(CAST(NEW.idAnimalWelfareAssociation AS CHAR), '-', CAST(NEW.idDonation AS CHAR)), 'Changed donation amount', CURRENT_USER());
    END IF;
    IF OLD.percentage != NEW.percentage THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationDetail', 'percentage', CAST(OLD.percentage AS CHAR), CAST(NEW.percentage AS CHAR), CONCAT(CAST(NEW.idAnimalWelfareAssociation AS CHAR), '-', CAST(NEW.idDonation AS CHAR)), 'Changed donation percentage', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDonationDetail;
DELIMITER //
CREATE TRIGGER beforeDeleteDonationDetail
    BEFORE DELETE ON DonationDetail
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL, CONCAT(CAST(OLD.idAnimalWelfareAssociation AS CHAR), '-', CAST(OLD.idDonation AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Donation
DROP TRIGGER IF EXISTS beforeInsertDonation;
DELIMITER //
CREATE TRIGGER beforeInsertDonation
    BEFORE INSERT ON Donation
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDonation;
DELIMITER //
CREATE TRIGGER beforeUpdateDonation
    BEFORE UPDATE ON Donation
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated person', CURRENT_USER());
    END IF;
    IF OLD.idDonationType != NEW.idDonationType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', 'idDonationType', CAST(OLD.idDonationType AS CHAR), CAST(NEW.idDonationType AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated donation type', CURRENT_USER());
    END IF;
    IF OLD.idCurrencyType != NEW.idCurrencyType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', 'idCurrencyType', CAST(OLD.idCurrencyType AS CHAR), CAST(NEW.idCurrencyType AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated currency type', CURRENT_USER());
    END IF;
    IF OLD.idReward != NEW.idReward THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', 'idReward', CAST(OLD.idReward AS CHAR), CAST(NEW.idReward AS CHAR), CAST(NEW.id AS CHAR), 'Changed id of associated reward', CURRENT_USER());
    END IF;
    IF OLD.donationDate != NEW.donationDate THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', 'donationDate', CAST(OLD.donationDate AS CHAR), CAST(NEW.donationDate AS CHAR), CAST(NEW.id AS CHAR), 'Changed donation date', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDonation;
DELIMITER //
CREATE TRIGGER beforeDeleteDonation
    BEFORE DELETE ON Donation
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Donation', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ===================================================
-- ==== Triggers tablas usadas para el FosterHome ====
-- ===================================================
-- FosterHomeStatus
DROP TRIGGER IF EXISTS beforeInsertFosterHomeStatus;
DELIMITER //
CREATE TRIGGER beforeInsertFosterHomeStatus
    BEFORE INSERT ON FosterHomeStatus
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateFosterHomeStatus;
DELIMITER //
CREATE TRIGGER beforeUpdateFosterHomeStatus
    BEFORE UPDATE ON FosterHomeStatus
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed status name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteFosterHomeStatus;
DELIMITER //
CREATE TRIGGER beforeDeleteFosterHomeStatus
    BEFORE DELETE ON FosterHomeStatus
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FosterHome
DROP TRIGGER IF EXISTS beforeInsertFosterHome;
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome
    BEFORE INSERT ON FosterHome
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', NULL, NULL, NULL, CAST(NEW.idFosterHome AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateFosterHome;
DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome
    BEFORE UPDATE ON FosterHome
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', 'idLocation', CAST(OLD.idLocation AS CHAR), CAST(NEW.idLocation AS CHAR), CAST(NEW.idFosterHome AS CHAR), 'Changed associated location', CURRENT_USER());
    END IF;
    IF OLD.idFosterHomeStatus != NEW.idFosterHomeStatus THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', 'idFosterHomeStatus', CAST(OLD.idFosterHomeStatus AS CHAR), CAST(NEW.idFosterHomeStatus AS CHAR), CAST(NEW.idFosterHome AS CHAR), 'Changed status of foster home', CURRENT_USER());
    END IF;
    IF OLD.maxCapacity != NEW.maxCapacity THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', 'maxCapacity', CAST(OLD.maxCapacity AS CHAR), CAST(NEW.maxCapacity AS CHAR), CAST(NEW.idFosterHome AS CHAR), 'Changed max capacity', CURRENT_USER());
    END IF;
    IF OLD.requiresFoodDonation != NEW.requiresFoodDonation THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', 'requiresFoodDonation', CAST(OLD.requiresFoodDonation AS CHAR), CAST(NEW.requiresFoodDonation AS CHAR), CAST(NEW.idFosterHome AS CHAR), 'Changed food donation requirement', CURRENT_USER());
    END IF;
    IF OLD.petCount != NEW.petCount THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', 'petCount', CAST(OLD.petCount AS CHAR), CAST(NEW.petCount AS CHAR), CAST(NEW.idFosterHome AS CHAR), 'Changed current pet count', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteFosterHome;
DELIMITER //
CREATE TRIGGER beforeDeleteFosterHome
    BEFORE DELETE ON FosterHome
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', NULL, NULL, NULL, CAST(OLD.idFosterHome AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FosterHome_x_petSize
DROP TRIGGER IF EXISTS beforeInsertFosterHome_x_petSize;
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome_x_petSize
    BEFORE INSERT ON FosterHome_x_petSize
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL, NULL, CONCAT(CAST(NEW.idFosterHome AS CHAR), '-', CAST(NEW.idPetSize AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateFosterHome_x_petSize;
DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome_x_petSize
    BEFORE UPDATE ON FosterHome_x_petSize
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforDeleteFosterHome_x_petSize;
DELIMITER //
CREATE TRIGGER beforDeleteFosterHome_x_petSize
    BEFORE DELETE ON FosterHome_x_petSize
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL, NULL, CONCAT(CAST(OLD.idFosterHome AS CHAR), '-', CAST(OLD.idPetSize AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FosterHome_x_petType
DROP TRIGGER IF EXISTS beforeInsertFosterHome_x_petType;
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome_x_petType
    BEFORE INSERT ON FosterHome_x_petType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL, NULL, CONCAT(CAST(NEW.idFosterHome AS CHAR), '-', CAST(NEW.idPetType AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateFosterHome_x_petType;
DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome_x_petType
    BEFORE UPDATE ON FosterHome_x_petType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforDeleteFosterHome_x_petType;
DELIMITER //
CREATE TRIGGER beforDeleteFosterHome_x_petType
    BEFORE DELETE ON FosterHome_x_petType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL, NULL, CONCAT(CAST(OLD.idFosterHome AS CHAR), '-', CAST(OLD.idPetType AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- Triggers tablas House, Adopter y adoption
-- ================================================
-- HouseType
DROP TRIGGER IF EXISTS beforeInsertHouseType;
DELIMITER //
CREATE TRIGGER beforeInsertHouseType
    BEFORE INSERT ON HouseType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'HouseType', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateHouseType;
DELIMITER //
CREATE TRIGGER beforeUpdateHouseType
    BEFORE UPDATE ON HouseType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'HouseType', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed house type name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteHouseType;
DELIMITER //
CREATE TRIGGER beforeDeleteHouseType
    BEFORE DELETE ON HouseType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'HouseType', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- House
DROP TRIGGER IF EXISTS beforeInsertHouse;
DELIMITER //
CREATE TRIGGER beforeInsertHouse
    BEFORE INSERT ON House
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateHouse;
DELIMITER //
CREATE TRIGGER beforeUpdateHouse
    BEFORE UPDATE ON House
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idHouseType != NEW.idHouseType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', 'idHouseType', CAST(OLD.idHouseType AS CHAR), CAST(NEW.idHouseType AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated house type', CURRENT_USER());
    END IF;
    IF OLD.hasYard != NEW.hasYard THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', 'hasYard', CAST(OLD.hasYard AS CHAR), CAST(NEW.hasYard AS CHAR), CAST(NEW.id AS CHAR), 'Changed yard availability flag', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteHouse;
DELIMITER //
CREATE TRIGGER beforeDeleteHouse
    BEFORE DELETE ON House -- CORREGIDO: antes decía HouseType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ExerciseTime
DROP TRIGGER IF EXISTS beforeInsertExerciseTime;
DELIMITER //
CREATE TRIGGER beforeInsertExerciseTime
    BEFORE INSERT ON ExerciseTime
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ExerciseTime', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateExerciseTime;
DELIMITER //
CREATE TRIGGER beforeUpdateExerciseTime
    BEFORE UPDATE ON ExerciseTime
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.value != NEW.value THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ExerciseTime', 'value', CAST(OLD.value AS CHAR), CAST(NEW.value AS CHAR), CAST(NEW.id AS CHAR), 'Changed exercise time value', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteExerciseTime;
DELIMITER //
CREATE TRIGGER beforeDeleteExerciseTime
    BEFORE DELETE ON ExerciseTime
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ExerciseTime', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Adopter
DROP TRIGGER IF EXISTS beforeInsertAdopter;
DELIMITER //
CREATE TRIGGER beforeInsertAdopter
    BEFORE INSERT ON Adopter
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', NULL, NULL, NULL, CAST(NEW.idAdopter AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateAdopter;
DELIMITER //
CREATE TRIGGER beforeUpdateAdopter
    BEFORE UPDATE ON Adopter
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idHouse != NEW.idHouse THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', 'idHouse', CAST(OLD.idHouse AS CHAR), CAST(NEW.idHouse AS CHAR), CAST(NEW.idAdopter AS CHAR), 'Changed associated house', CURRENT_USER());
    END IF;
    IF OLD.idExerciseTime != NEW.idExerciseTime THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', 'idExerciseTime', CAST(OLD.idExerciseTime AS CHAR), CAST(NEW.idExerciseTime AS CHAR), CAST(NEW.idAdopter AS CHAR), 'Changed exercise time', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteAdopter;
DELIMITER //
CREATE TRIGGER beforeDeleteAdopter
    BEFORE DELETE ON Adopter
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', NULL, NULL, NULL, CAST(OLD.idAdopter AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- OtherPet
DROP TRIGGER IF EXISTS beforeInsertOtherPet;
DELIMITER //
CREATE TRIGGER beforeInsertOtherPet
    BEFORE INSERT ON OtherPet
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateOtherPet;
DELIMITER //
CREATE TRIGGER beforeUpdateOtherPet
    BEFORE UPDATE ON OtherPet
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPetBreed != NEW.idPetBreed THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', 'idPetBreed', CAST(OLD.idPetBreed AS CHAR), CAST(NEW.idPetBreed AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated pet breed', CURRENT_USER());
    END IF;
    IF OLD.idAdopter != NEW.idAdopter THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', 'idAdopter', CAST(OLD.idAdopter AS CHAR), CAST(NEW.idAdopter AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated adopter', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteOtherPet;
DELIMITER //
CREATE TRIGGER beforeDeleteOtherPet
    BEFORE DELETE ON OtherPet
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Adoption
DROP TRIGGER IF EXISTS beforeInsertAdoption;
DELIMITER //
CREATE TRIGGER beforeInsertAdoption
    BEFORE INSERT ON Adoption
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateAdoption;
DELIMITER //
CREATE TRIGGER beforeUpdateAdoption
    BEFORE UPDATE ON Adoption
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated person', CURRENT_USER());
    END IF;
    IF OLD.idAdopter != NEW.idAdopter THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', 'idAdopter', CAST(OLD.idAdopter AS CHAR), CAST(NEW.idAdopter AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated adopter', CURRENT_USER());
    END IF;
    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', 'idPet', CAST(OLD.idPet AS CHAR), CAST(NEW.idPet AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated pet', CURRENT_USER());
    END IF;
    IF OLD.adoptionDate != NEW.adoptionDate THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', 'adoptionDate', CAST(OLD.adoptionDate AS CHAR), CAST(NEW.adoptionDate AS CHAR), CAST(NEW.id AS CHAR), 'Changed adoption date', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteAdoption;
DELIMITER //
CREATE TRIGGER beforeDeleteAdoption
    BEFORE DELETE ON Adoption
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FollowUp
DROP TRIGGER IF EXISTS beforeInsertFollowUp;
DELIMITER //
CREATE TRIGGER beforeInsertFollowUp
    BEFORE INSERT ON FollowUp
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateFollowUp;
DELIMITER //
CREATE TRIGGER beforeUpdateFollowUp
    BEFORE UPDATE ON FollowUp
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idAdoption != NEW.idAdoption THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', 'idAdoption', CAST(OLD.idAdoption AS CHAR), CAST(NEW.idAdoption AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated adoption', CURRENT_USER());
    END IF;
    IF OLD.comments != NEW.comments THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', 'comments', OLD.comments, NEW.comments, CAST(NEW.id AS CHAR), 'Changed comments', CURRENT_USER());
    END IF;
    IF OLD.followUpDate != NEW.followUpDate THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', 'followUpDate', CAST(OLD.followUpDate AS CHAR), CAST(NEW.followUpDate AS CHAR), CAST(NEW.id AS CHAR), 'Changed follow-up date', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteFollowUp;
DELIMITER //
CREATE TRIGGER beforeDeleteFollowUp
    BEFORE DELETE ON FollowUp
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetOwnerRating
DROP TRIGGER IF EXISTS beforeInsertPetOwnerRating;
DELIMITER //
CREATE TRIGGER beforeInsertPetOwnerRating
    BEFORE INSERT ON PetOwnerRating
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetOwnerRating;
DELIMITER //
CREATE TRIGGER beforeUpdatePetOwnerRating
    BEFORE UPDATE ON PetOwnerRating
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idAdoption != NEW.idAdoption THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', 'idAdoption', CAST(OLD.idAdoption AS CHAR), CAST(NEW.idAdoption AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated adoption', CURRENT_USER());
    END IF;
    IF OLD.rating != NEW.rating THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', 'rating', CAST(OLD.rating AS CHAR), CAST(NEW.rating AS CHAR), CAST(NEW.id AS CHAR), 'Changed rating score', CURRENT_USER());
    END IF;
    IF OLD.notes != NEW.notes THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', 'notes', OLD.notes, NEW.notes, CAST(NEW.id AS CHAR), 'Changed rating notes', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetOwnerRating;
DELIMITER //
CREATE TRIGGER beforeDeletePetOwnerRating
    BEFORE DELETE ON PetOwnerRating
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- ==== Triggers tablas relacionadas a Photo ====
-- ================================================
-- PhotoType
DROP TRIGGER IF EXISTS beforeInsertPhotoType;
DELIMITER //
CREATE TRIGGER beforeInsertPhotoType
    BEFORE INSERT ON PhotoType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PhotoType', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePhotoType;
DELIMITER //
CREATE TRIGGER beforeUpdatePhotoType
    BEFORE UPDATE ON PhotoType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PhotoType', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed photo type name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePhotoType;
DELIMITER //
CREATE TRIGGER beforeDeletePhotoType
    BEFORE DELETE ON PhotoType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PhotoType', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Photo
DROP TRIGGER IF EXISTS beforeInsertPhoto;
DELIMITER //
CREATE TRIGGER beforeInsertPhoto
    BEFORE INSERT ON Photo
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePhoto;
DELIMITER //
CREATE TRIGGER beforeUpdatePhoto
    BEFORE UPDATE ON Photo
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idFollowUp != NEW.idFollowUp THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', 'idFollowUp', CAST(OLD.idFollowUp AS CHAR), CAST(NEW.idFollowUp AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated follow-up', CURRENT_USER());
    END IF;
    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', 'idPet', CAST(OLD.idPet AS CHAR), CAST(NEW.idPet AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated pet', CURRENT_USER());
    END IF;
    IF OLD.idPhotoType != NEW.idPhotoType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', 'idPhotoType', CAST(OLD.idPhotoType AS CHAR), CAST(NEW.idPhotoType AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated photo type', CURRENT_USER());
    END IF;
    IF OLD.photoURL != NEW.photoURL THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', 'photoURL', OLD.photoURL, NEW.photoURL, CAST(NEW.id AS CHAR), 'Changed photo URL', CURRENT_USER());
    END IF;
    IF OLD.uploadDate != NEW.uploadDate THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', 'uploadDate', CAST(OLD.uploadDate AS CHAR), CAST(NEW.uploadDate AS CHAR), CAST(NEW.id AS CHAR), 'Changed photo upload date', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePhoto;
DELIMITER //
CREATE TRIGGER beforeDeletePhoto
    BEFORE DELETE ON Photo
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- =======================================================
-- ==== Triggers tablas de enfermedades y veterinario ====
-- =======================================================
-- Veterinarian
DROP TRIGGER IF EXISTS beforeInsertVeterinarian;
DELIMITER //
CREATE TRIGGER beforeInsertVeterinarian
    BEFORE INSERT ON Veterinarian
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Veterinarian', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateVeterinarian;
DELIMITER //
CREATE TRIGGER beforeUpdateVeterinarian
    BEFORE UPDATE ON Veterinarian
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Veterinarian', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated person', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteVeterinarian;
DELIMITER //
CREATE TRIGGER beforeDeleteVeterinarian
    BEFORE DELETE ON Veterinarian
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Veterinarian', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Disease
DROP TRIGGER IF EXISTS beforeInsertDisease;
DELIMITER //
CREATE TRIGGER beforeInsertDisease
    BEFORE INSERT ON Disease
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDisease;
DELIMITER //
CREATE TRIGGER beforeUpdateDisease
    BEFORE UPDATE ON Disease
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed disease name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDisease;
DELIMITER //
CREATE TRIGGER beforeDeleteDisease
    BEFORE DELETE ON Disease
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Disease_x_pet
DROP TRIGGER IF EXISTS beforeInsertDiseaseXPet;
DELIMITER //
CREATE TRIGGER beforeInsertDiseaseXPet
    BEFORE INSERT ON Disease_x_pet
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease_x_pet', NULL, NULL, NULL, CONCAT(CAST(NEW.idDisease AS CHAR), '-', CAST(NEW.idPet AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateDiseaseXPet;
DELIMITER //
CREATE TRIGGER beforeUpdateDiseaseXPet
    BEFORE UPDATE ON Disease_x_pet
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteDiseaseXPet;
DELIMITER //
CREATE TRIGGER beforeDeleteDiseaseXPet
    BEFORE DELETE ON Disease_x_pet
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease_x_pet', NULL, NULL, NULL, CONCAT(CAST(OLD.idDisease AS CHAR), '-', CAST(OLD.idPet AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Treatment
DROP TRIGGER IF EXISTS beforeInsertTreatment;
DELIMITER //
CREATE TRIGGER beforeInsertTreatment
    BEFORE INSERT ON Treatment
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateTreatment;
DELIMITER //
CREATE TRIGGER beforeUpdateTreatment
    BEFORE UPDATE ON Treatment
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed treatment name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteTreatment;
DELIMITER //
CREATE TRIGGER beforeDeleteTreatment
    BEFORE DELETE ON Treatment
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Treatment_x_disease
DROP TRIGGER IF EXISTS beforeInsertTreatmentXDisease;
DELIMITER //
CREATE TRIGGER beforeInsertTreatmentXDisease
    BEFORE INSERT ON Treatment_x_disease
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment_x_disease', NULL, NULL, NULL, CONCAT(CAST(NEW.idDisease AS CHAR), '-', CAST(NEW.idTreatment AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateTreatmentXDisease;
DELIMITER //
CREATE TRIGGER beforeUpdateTreatmentXDisease
    BEFORE UPDATE ON Treatment_x_disease
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.timeLength != NEW.timeLength THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment_x_disease', 'timeLength', CAST(OLD.timeLength AS CHAR), CAST(NEW.timeLength AS CHAR), CONCAT(CAST(NEW.idDisease AS CHAR), '-', CAST(NEW.idTreatment AS CHAR)), 'Changed treatment time length', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteTreatmentXDisease;
DELIMITER //
CREATE TRIGGER beforeDeleteTreatmentXDisease
    BEFORE DELETE ON Treatment_x_disease
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment_x_disease', NULL, NULL, NULL, CONCAT(CAST(OLD.idDisease AS CHAR), '-', CAST(OLD.idTreatment AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Medication
DROP TRIGGER IF EXISTS beforeInsertMedication;
DELIMITER //
CREATE TRIGGER beforeInsertMedication
    BEFORE INSERT ON Medication
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateMedication;
DELIMITER //
CREATE TRIGGER beforeUpdateMedication
    BEFORE UPDATE ON Medication
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed medication name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteMedication;
DELIMITER //
CREATE TRIGGER beforeDeleteMedication
    BEFORE DELETE ON Medication
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Medication_x_treatment
DROP TRIGGER IF EXISTS beforeInsertMedicationXTreatment;
DELIMITER //
CREATE TRIGGER beforeInsertMedicationXTreatment
    BEFORE INSERT ON Medication_x_treatment
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication_x_treatment', NULL, NULL, NULL, CONCAT(CAST(NEW.idMedication AS CHAR), '-', CAST(NEW.idTreatment AS CHAR)), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateMedicationXTreatment;
DELIMITER //
CREATE TRIGGER beforeUpdateMedicationXTreatment
    BEFORE UPDATE ON Medication_x_treatment
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.dosage != NEW.dosage THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication_x_treatment', 'dosage', CAST(OLD.dosage AS CHAR), CAST(NEW.dosage AS CHAR), CONCAT(CAST(NEW.idMedication AS CHAR), '-', CAST(NEW.idTreatment AS CHAR)), 'Changed medication dosage', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteMedicationXTreatment;
DELIMITER //
CREATE TRIGGER beforeDeleteMedicationXTreatment
    BEFORE DELETE ON Medication_x_treatment
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication_x_treatment', NULL, NULL, NULL, CONCAT(CAST(OLD.idMedication AS CHAR), '-', CAST(OLD.idTreatment AS CHAR)), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- ==== Triggers tablas Pet ====
-- ================================================
-- PetType
DROP TRIGGER IF EXISTS beforeInsertPetType;
DELIMITER //
CREATE TRIGGER beforeInsertPetType
    BEFORE INSERT ON PetType
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetType', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetType;
DELIMITER //
CREATE TRIGGER beforeUpdatePetType
    BEFORE UPDATE ON PetType
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetType', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet type name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetType;
DELIMITER //
CREATE TRIGGER beforeDeletePetType
    BEFORE DELETE ON PetType
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetType', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetBreed
DROP TRIGGER IF EXISTS beforeInsertPetBreed;
DELIMITER //
CREATE TRIGGER beforeInsertPetBreed
    BEFORE INSERT ON PetBreed
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetBreed;
DELIMITER //
CREATE TRIGGER beforeUpdatePetBreed
    BEFORE UPDATE ON PetBreed
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed breed name', CURRENT_USER());
    END IF;
    IF OLD.idPetType != NEW.idPetType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', 'idPetType', CAST(OLD.idPetType AS CHAR), CAST(NEW.idPetType AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated pet type', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetBreed;
DELIMITER //
CREATE TRIGGER beforeDeletePetBreed
    BEFORE DELETE ON PetBreed
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetSize
DROP TRIGGER IF EXISTS beforeInsertPetSize;
DELIMITER //
CREATE TRIGGER beforeInsertPetSize
    BEFORE INSERT ON PetSize
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSize', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetSize;
DELIMITER //
CREATE TRIGGER beforeUpdatePetSize
    BEFORE UPDATE ON PetSize
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSize', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet size name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetSize;
DELIMITER //
CREATE TRIGGER beforeDeletePetSize
    BEFORE DELETE ON PetSize
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSize', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetColor
DROP TRIGGER IF EXISTS beforeInsertPetColor;
DELIMITER //
CREATE TRIGGER beforeInsertPetColor
    BEFORE INSERT ON PetColor
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetColor', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetColor;
DELIMITER //
CREATE TRIGGER beforeUpdatePetColor
    BEFORE UPDATE ON PetColor
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetColor', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet color name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetColor;
DELIMITER //
CREATE TRIGGER beforeDeletePetColor
    BEFORE DELETE ON PetColor
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetColor', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetSeverity
DROP TRIGGER IF EXISTS beforeInsertPetSeverity;
DELIMITER //
CREATE TRIGGER beforeInsertPetSeverity
    BEFORE INSERT ON PetSeverity
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSeverity', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetSeverity;
DELIMITER //
CREATE TRIGGER beforeUpdatePetSeverity
    BEFORE UPDATE ON PetSeverity
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSeverity', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet severity name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetSeverity;
DELIMITER //
CREATE TRIGGER beforeDeletePetSeverity
    BEFORE DELETE ON PetSeverity
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSeverity', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetEnergy
DROP TRIGGER IF EXISTS beforeInsertPetEnergy;
DELIMITER //
CREATE TRIGGER beforeInsertPetEnergy
    BEFORE INSERT ON PetEnergy
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetEnergy', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetEnergy;
DELIMITER //
CREATE TRIGGER beforeUpdatePetEnergy
    BEFORE UPDATE ON PetEnergy
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetEnergy', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet energy name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetEnergy;
DELIMITER //
CREATE TRIGGER beforeDeletePetEnergy
    BEFORE DELETE ON PetEnergy
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetEnergy', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetTrainability
DROP TRIGGER IF EXISTS beforeInsertPetTrainability;
DELIMITER //
CREATE TRIGGER beforeInsertPetTrainability
    BEFORE INSERT ON PetTrainability
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetTrainability', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetTrainability;
DELIMITER //
CREATE TRIGGER beforeUpdatePetTrainability
    BEFORE UPDATE ON PetTrainability
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetTrainability', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet trainability name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetTrainability;
DELIMITER //
CREATE TRIGGER beforeDeletePetTrainability
    BEFORE DELETE ON PetTrainability
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetTrainability', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetStatus
DROP TRIGGER IF EXISTS beforeInsertPetStatus;
DELIMITER //
CREATE TRIGGER beforeInsertPetStatus
    BEFORE INSERT ON PetStatus
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetStatus', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePetStatus;
DELIMITER //
CREATE TRIGGER beforeUpdatePetStatus
    BEFORE UPDATE ON PetStatus
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetStatus', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet status name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePetStatus;
DELIMITER //
CREATE TRIGGER beforeDeletePetStatus
    BEFORE DELETE ON PetStatus
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetStatus', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Pet
DROP TRIGGER IF EXISTS beforeInsertPet;
DELIMITER //
CREATE TRIGGER beforeInsertPet
    BEFORE INSERT ON Pet
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdatePet;
DELIMITER //
CREATE TRIGGER beforeUpdatePet
    BEFORE UPDATE ON Pet
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idLocation', CAST(OLD.idLocation AS CHAR), CAST(NEW.idLocation AS CHAR), CAST(NEW.id AS CHAR), 'Changed pet location', CURRENT_USER());
    END IF;
    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPerson', CAST(OLD.idPerson AS CHAR), CAST(NEW.idPerson AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated person', CURRENT_USER());
    END IF;
    IF OLD.idPetBreed != NEW.idPetBreed THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetBreed', CAST(OLD.idPetBreed AS CHAR), CAST(NEW.idPetBreed AS CHAR), CAST(NEW.id AS CHAR), 'Changed breed', CURRENT_USER());
    END IF;
    IF OLD.idPetSize != NEW.idPetSize THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetSize', CAST(OLD.idPetSize AS CHAR), CAST(NEW.idPetSize AS CHAR), CAST(NEW.id AS CHAR), 'Changed size', CURRENT_USER());
    END IF;
    IF OLD.idPetColor != NEW.idPetColor THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetColor', CAST(OLD.idPetColor AS CHAR), CAST(NEW.idPetColor AS CHAR), CAST(NEW.id AS CHAR), 'Changed color', CURRENT_USER());
    END IF;
    IF OLD.idPetSeverity != NEW.idPetSeverity THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetSeverity', CAST(OLD.idPetSeverity AS CHAR), CAST(NEW.idPetSeverity AS CHAR), CAST(NEW.id AS CHAR), 'Changed severity', CURRENT_USER());
    END IF;
    IF OLD.idPetEnergy != NEW.idPetEnergy THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetEnergy', CAST(OLD.idPetEnergy AS CHAR), CAST(NEW.idPetEnergy AS CHAR), CAST(NEW.id AS CHAR), 'Changed energy level', CURRENT_USER());
    END IF;
    IF OLD.idPetTrainability != NEW.idPetTrainability THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetTrainability', CAST(OLD.idPetTrainability AS CHAR), CAST(NEW.idPetTrainability AS CHAR), CAST(NEW.id AS CHAR), 'Changed trainability level', CURRENT_USER());
    END IF;
    IF OLD.idPetStatus != NEW.idPetStatus THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idPetStatus', CAST(OLD.idPetStatus AS CHAR), CAST(NEW.idPetStatus AS CHAR), CAST(NEW.id AS CHAR), 'Changed pet status', CURRENT_USER());
    END IF;
    IF OLD.idVeterinarian != NEW.idVeterinarian THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'idVeterinarian', CAST(OLD.idVeterinarian AS CHAR), CAST(NEW.idVeterinarian AS CHAR), CAST(NEW.id AS CHAR), 'Changed veterinarian', CURRENT_USER());
    END IF;
    IF OLD.chipId != NEW.chipId THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'chipId', OLD.chipId, NEW.chipId, CAST(NEW.id AS CHAR), 'Changed chip ID', CURRENT_USER());
    END IF;
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed pet name', CURRENT_USER());
    END IF;
    IF OLD.requiresSpace != NEW.requiresSpace THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'requiresSpace', CAST(OLD.requiresSpace AS CHAR), CAST(NEW.requiresSpace AS CHAR), CAST(NEW.id AS CHAR), 'Changed space requirement', CURRENT_USER());
    END IF;
    IF OLD.estimatedAge != NEW.estimatedAge THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', 'estimatedAge', CAST(OLD.estimatedAge AS CHAR), CAST(NEW.estimatedAge AS CHAR), CAST(NEW.id AS CHAR), 'Changed estimated age', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeletePet;
DELIMITER //
CREATE TRIGGER beforeDeletePet
    BEFORE DELETE ON Pet
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- ==== Triggers recompensa y parametros ====
-- ================================================
-- Reward
DROP TRIGGER IF EXISTS beforeInsertReward;
DELIMITER //
CREATE TRIGGER beforeInsertReward
    BEFORE INSERT ON Reward
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateReward;
DELIMITER //
CREATE TRIGGER beforeUpdateReward
    BEFORE UPDATE ON Reward
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', 'idPet', CAST(OLD.idPet AS CHAR), CAST(NEW.idPet AS CHAR), CAST(NEW.id AS CHAR), 'Changed associated pet', CURRENT_USER());
    END IF;
    IF OLD.idCurrencyType != NEW.idCurrencyType THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', 'idCurrencyType', CAST(OLD.idCurrencyType AS CHAR), CAST(NEW.idCurrencyType AS CHAR), CAST(NEW.id AS CHAR), 'Changed currency type', CURRENT_USER());
    END IF;
    IF OLD.amount != NEW.amount THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', 'amount', CAST(OLD.amount AS CHAR), CAST(NEW.amount AS CHAR), CAST(NEW.id AS CHAR), 'Changed reward amount', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteReward;
DELIMITER //
CREATE TRIGGER beforeDeleteReward
    BEFORE DELETE ON Reward
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Parameter
DROP TRIGGER IF EXISTS beforeInsertParameter;
DELIMITER //
CREATE TRIGGER beforeInsertParameter
    BEFORE INSERT ON Parameter
    FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', NULL, NULL, NULL, CAST(NEW.id AS CHAR), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeUpdateParameter;
DELIMITER //
CREATE TRIGGER beforeUpdateParameter
    BEFORE UPDATE ON Parameter
    FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.description != NEW.description THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', 'description', OLD.description, NEW.description, CAST(NEW.id AS CHAR), 'Changed parameter description', CURRENT_USER());
    END IF;
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', 'name', OLD.name, NEW.name, CAST(NEW.id AS CHAR), 'Changed parameter name', CURRENT_USER());
    END IF;
    IF OLD.textValue != NEW.textValue THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', 'textValue', OLD.textValue, NEW.textValue, CAST(NEW.id AS CHAR), 'Changed parameter text value', CURRENT_USER());
    END IF;
    IF OLD.numberValue != NEW.numberValue THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', 'value', CAST(OLD.numberValue AS CHAR), CAST(NEW.numberValue AS CHAR), CAST(NEW.id AS CHAR), 'Changed parameter number value', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DROP TRIGGER IF EXISTS beforeDeleteParameter;
DELIMITER //
CREATE TRIGGER beforeDeleteParameter
    BEFORE DELETE ON Parameter
    FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', NULL, NULL, NULL, CAST(OLD.id AS CHAR), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;