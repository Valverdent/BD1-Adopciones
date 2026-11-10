USE ADOPCION_APP;
-- ================================================
-- ==== Triggers relacionados al usuario ====
-- ================================================
-- UserStatus
DELIMITER //
CREATE TRIGGER beforeInsertUserStatus
BEFORE INSERT ON UserStatus
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateUserStatus
BEFORE UPDATE ON UserStatus
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', 'name', TO_CHAR(OLD.name),
            TO_CHAR(NEW.name), TO_CHAR(NEW.id), 'Changed status name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteUserStatus
BEFORE DELETE ON UserStatus
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'UserStatus', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Role
DELIMITER //
CREATE TRIGGER beforeInsertRole
BEFORE INSERT ON `Role`
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateRole
BEFORE UPDATE ON `Role`
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', 'name', TO_CHAR(OLD.name),
            TO_CHAR(NEW.name), TO_CHAR(NEW.id), 'Changed role name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteRole
BEFORE DELETE ON `Role`
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Role', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- User
DELIMITER //
CREATE TRIGGER beforeInsertUser
BEFORE INSERT ON `User`
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateUser
BEFORE UPDATE ON `User`
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    
    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idPerson', TO_CHAR(OLD.idPerson), 
            TO_CHAR(NEW.idPerson), TO_CHAR(NEW.id), 'Changed id of associated person', CURRENT_USER());
    END IF;

    IF OLD.idRole != NEW.idRole THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idRole', TO_CHAR(OLD.idRole),
            TO_CHAR(NEW.idRole), TO_CHAR(NEW.id), 'Changed id of associated role', CURRENT_USER()
        );
    END IF;

    IF OLD.idUserStatus != NEW.idUserStatus THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', 'idUserStatus', 
            TO_CHAR(OLD.idUserStatus), TO_CHAR(NEW.idUserStatus),
            TO_CHAR(NEW.id), 'Changed id of associated CURRENT_USER() status', CURRENT_USER()
        );
    END IF;

    IF OLD.username != NEW.username THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'User', 'username',
            TO_CHAR(OLD.username), TO_CHAR(NEW.username),
            TO_CHAR(NEW.id), 'Changed username', CURRENT_USER()
        );
    END IF;

    IF OLD.password != NEW.password THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'User', 'password',
            TO_CHAR(OLD.password), TO_CHAR(NEW.password),
            TO_CHAR(NEW.id), 'Changed password', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteUser
BEFORE DELETE ON `User`
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'User', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- BlackList
DELIMITER //
CREATE TRIGGER beforeInsertBlackList
BEFORE INSERT ON BlackList
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateBlackList
BEFORE UPDATE ON BlackList
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF UPDATING('idPerson') AND (OLD.idPerson != NEW.idPerson) THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'BlackList', 'idPerson',
            TO_CHAR(OLD.idPerson), TO_CHAR(NEW.idPerson),
            TO_CHAR(NEW.id), 'Changed id of associated person', CURRENT_USER()
        );
        END IF;

    IF UPDATING('blackListDate') AND (OLD.blackListDate != NEW.blackListDate) THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'BlackList', 'blackListDate',
            TO_CHAR(OLD.blackListDate), TO_CHAR(NEW.blackListDate),
            TO_CHAR(NEW.id), 'Changed date when blacklist record was created', CURRENT_USER()
        );
    END IF;

    IF UPDATING('blackListReason') AND (OLD.blackListReason != NEW.blackListReason) THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'BlackList', 'blackListReason',
            TO_CHAR(OLD.blackListReason), TO_CHAR(NEW.blackListReason),
            TO_CHAR(NEW.id), 'Changed reason why blacklist record was created', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteBlackList
BEFORE DELETE ON BlackList
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'BlackList', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Person
DELIMITER //
CREATE TRIGGER beforeInsertPerson
BEFORE INSERT ON Person
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePerson
BEFORE UPDATE ON Person
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Person', 'idLocation',
            TO_CHAR(OLD.idLocation), TO_CHAR(NEW.idLocation),
            TO_CHAR(NEW.id), 'Changed id of associated location', CURRENT_USER()
        );
        END IF;

    IF OLD.firstName != NEW.firstName THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Person', 'firstName',
            TO_CHAR(OLD.firstName), TO_CHAR(NEW.firstName),
            TO_CHAR(NEW.id), 'Changed first name info', CURRENT_USER()
        );
    END IF;

    IF OLD.middleName != NEW.middleName THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Person', 'middleName',
            TO_CHAR(OLD.middleName), TO_CHAR(NEW.middleName),
            TO_CHAR(NEW.id), 'Changed middle name info', CURRENT_USER()
        );
    END IF;

    IF OLD.firstLastName != NEW.firstLastName THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Person', 'firstLastName',
            TO_CHAR(OLD.firstLastName), TO_CHAR(NEW.firstLastName),
            TO_CHAR(NEW.id), 'Changed first last name info', CURRENT_USER()
        );
    END IF;

    IF OLD.secondLastName != NEW.secondLastName THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Person', 'secondLastName',
            TO_CHAR(OLD.secondLastName), TO_CHAR(NEW.secondLastName),
            TO_CHAR(NEW.id), 'Changed second last name info', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePerson
BEFORE DELETE ON Person
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Person', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ContactEmail
DELIMITER //
CREATE TRIGGER beforeInsertContactEmail
BEFORE INSERT ON ContactEmail
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateContactEmail
BEFORE UPDATE ON ContactEmail
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.email != NEW.email THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'ContactEmail', 'email',
            TO_CHAR(OLD.email), TO_CHAR(NEW.email),
            TO_CHAR(NEW.id), 'Changed email address', CURRENT_USER()
        );
    END IF;

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'ContactEmail', 'idPerson',
            TO_CHAR(OLD.idPerson), TO_CHAR(NEW.idPerson),
            TO_CHAR(NEW.id), 'Changed id of associated person', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteContactEmail
BEFORE DELETE ON ContactEmail
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactEmail', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ContactNumber
DELIMITER //
CREATE TRIGGER beforeInsertContactNumber
BEFORE INSERT ON ContactNumber
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateContactNumber
BEFORE UPDATE ON ContactNumber
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.phoneNumber != NEW.phoneNumber THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'ContactNumber', 'phoneNumber',
            TO_CHAR(OLD.phoneNumber), TO_CHAR(NEW.phoneNumber),
            TO_CHAR(NEW.id), 'Changed phone number', CURRENT_USER()
        );
    END IF;

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'ContactEmail', 'idPerson',
            TO_CHAR(OLD.idPerson), TO_CHAR(NEW.idPerson),
            TO_CHAR(NEW.id), 'Changed id of associated person', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteContactNumber
BEFORE DELETE ON ContactNumber
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ContactNumber', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Country
DELIMITER //
CREATE TRIGGER beforeInsertCountry
BEFORE INSERT ON Country
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Country', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateCountry
BEFORE UPDATE ON Country
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Country', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed country name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteCountry
BEFORE DELETE ON Country
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Country', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- Province
DELIMITER //
CREATE TRIGGER beforeInsertProvince
BEFORE INSERT ON Province
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateProvince
BEFORE UPDATE ON Province
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Province', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed province name', CURRENT_USER()
        );
    END IF;

    IF OLD.idCountry != NEW.idCountry THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Province', 'idCountry',
            TO_CHAR(OLD.idCountry), TO_CHAR(NEW.idCountry),
            TO_CHAR(NEW.id), 'Changed id of associated country', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteProvince
BEFORE DELETE ON Province
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Province', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- Canton
DELIMITER //
CREATE TRIGGER beforeInsertCanton
BEFORE INSERT ON Canton
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateCanton
BEFORE UPDATE ON Canton
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Canton', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed Canton name', CURRENT_USER()
        );
    END IF;

    IF OLD.idProvince != NEW.idProvince THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Canton', 'idProvince',
            TO_CHAR(OLD.idProvince), TO_CHAR(NEW.idProvince),
            TO_CHAR(NEW.id), 'Changed id of associated province', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteCanton
BEFORE DELETE ON Canton
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Canton', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- District
DELIMITER //
CREATE TRIGGER beforeInsertDistrict
BEFORE INSERT ON District
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDistrict
BEFORE UPDATE ON District
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'District', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed District name', CURRENT_USER()
        );
    END IF;

    IF OLD.idCanton != NEW.idCanton THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'District', 'idCanton',
            TO_CHAR(OLD.idCanton), TO_CHAR(NEW.idCanton),
            TO_CHAR(NEW.id), 'Changed id of associated canton', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteDistrict
BEFORE DELETE ON District
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'District', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- Location
DELIMITER //
CREATE TRIGGER beforeInsertLocation
BEFORE INSERT ON Location
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateLocation
BEFORE UPDATE ON Location
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.address != NEW.address THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Location', 'address',
            TO_CHAR(OLD.address), TO_CHAR(NEW.address),
            TO_CHAR(NEW.id), 'Changed Location address', CURRENT_USER()
        );
    END IF;

    IF OLD.idDistrict != NEW.idDistrict THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Location', 'idDistrict',
            TO_CHAR(OLD.idDistrict), TO_CHAR(NEW.idDistrict),
            TO_CHAR(NEW.id), 'Changed id of associated district', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteLocation
BEFORE DELETE ON Location
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Location', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ======================================================================
-- ==== Triggers para tablas relacionadas a AnimalWelfareAssociation ====
-- ======================================================================
-- DonationType
DELIMITER //
CREATE TRIGGER beforeInsertDonationType
BEFORE INSERT ON DonationType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationType', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDonationType
BEFORE UPDATE ON DonationType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'DonationType', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed donation type name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteDonationType
BEFORE DELETE ON DonationType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'DonationType', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- CurrencyType
DELIMITER //
CREATE TRIGGER beforeInsertCurrencyType
BEFORE INSERT ON CurrencyType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'CurrencyType', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateCurrencyType
BEFORE UPDATE ON CurrencyType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'CurrencyType', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed currency type name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteCurrencyType
BEFORE DELETE ON CurrencyType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'CurrencyType', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;



-- AnimalWelfareAssociation
DELIMITER //
CREATE TRIGGER beforeInsertAnimalWelfareAssociation
BEFORE INSERT ON AnimalWelfareAssociation
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateAnimalWelfareAssociation
BEFORE UPDATE ON AnimalWelfareAssociation
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'AnimalWelfareAssociation', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed animal welfare association name', CURRENT_USER()
        );
    END IF;

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'AnimalWelfareAssociation', 'idLocation',
            TO_CHAR(OLD.idLocation), TO_CHAR(NEW.idLocation),
            TO_CHAR(NEW.id), 'Changed id of associated location', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteAnimalWelfareAssociation
BEFORE DELETE ON AnimalWelfareAssociation
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'AnimalWelfareAssociation', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- DonationDetail
DELIMITER //
CREATE TRIGGER beforeInsertDonationDetail
BEFORE INSERT ON DonationDetail
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog(
        'ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL,
        TO_CHAR(NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(NEW.idDonation),
        'New tuple insertion', CURRENT_USER()
    );
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDonationDetail
BEFORE UPDATE ON DonationDetail
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.amount != NEW.amount THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'DonationDetail', 'amount',
            TO_CHAR(OLD.amount), TO_CHAR(NEW.amount),
            TO_CHAR(NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(NEW.idDonation),
            'Changed donation amount', CURRENT_USER()
        );
    END IF;

    IF OLD.percentage != NEW.percentage THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'DonationDetail', 'percentage',
            TO_CHAR(OLD.percentage), TO_CHAR(NEW.percentage),
            TO_CHAR(NEW.idAnimalWelfareAssociation) || '-' || TO_CHAR(NEW.idDonation),
            'Changed donation percentage', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;   

DELIMITER //
CREATE TRIGGER beforeDeleteDonationDetail
BEFORE DELETE ON DonationDetail
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog(
        'ADOPCION_APP', 'DonationDetail', NULL, NULL, NULL,
        TO_CHAR(OLD.idAnimalWelfareAssociation) || '-' || TO_CHAR(OLD.idDonation),
        'Tuple deletion', CURRENT_USER()
    );
END;//
DELIMITER ;

-- Donation
DELIMITER //
CREATE TRIGGER beforeInsertDonation
BEFORE INSERT ON Donation
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog(
        'ADOPCION_APP', 'Donation', NULL, NULL, NULL,
        TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER()
    );
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDonation
BEFORE UPDATE ON Donation
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Donation', 'idPerson',
            TO_CHAR(OLD.idPerson), TO_CHAR(NEW.idPerson),
            TO_CHAR(NEW.id), 'Changed id of associated person', CURRENT_USER()
        );
    END IF;

    IF OLD.idDonationType != NEW.idDonationType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Donation', 'idDonationType',
            TO_CHAR(OLD.idDonationType), TO_CHAR(NEW.idDonationType),
            TO_CHAR(NEW.id), 'Changed id of associated donation type', CURRENT_USER()
        );
    END IF;

    IF OLD.idCurrencyType != NEW.idCurrencyType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Donation', 'idCurrencyType',
            TO_CHAR(OLD.idCurrencyType), TO_CHAR(NEW.idCurrencyType),
            TO_CHAR(NEW.id), 'Changed id of associated currency type', CURRENT_USER()
        );
    END IF;

    IF OLD.idReward != NEW.idReward THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Donation', 'idReward',
            TO_CHAR(OLD.idReward), TO_CHAR(NEW.idReward),
            TO_CHAR(NEW.id), 'Changed id of associated reward', CURRENT_USER()
        );
    END IF;

    IF OLD.donationDate != NEW.donationDate THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Donation', 'donationDate',
            TO_CHAR(OLD.donationDate), TO_CHAR(NEW.donationDate),
            TO_CHAR(NEW.id), 'Changed donation date', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteDonation
BEFORE DELETE ON Donation
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog(
        'ADOPCION_APP', 'Donation', NULL, NULL, NULL,
        TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER()
    );
END;//
DELIMITER ;

-- ===================================================
-- ==== Triggers tablas usadas para el FosterHome ====
-- ===================================================
-- FosterHomeStatus
DELIMITER //
CREATE TRIGGER beforeInsertFosterHomeStatus
BEFORE INSERT ON FosterHomeStatus
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateFosterHomeStatus
BEFORE UPDATE ON FosterHomeStatus
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
    
    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', 'name', TO_CHAR(OLD.name),
            TO_CHAR(NEW.name), TO_CHAR(NEW.id), 'Changed status name', CURRENT_USER());
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteFosterHomeStatus
BEFORE DELETE ON FosterHomeStatus
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHomeStatus', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- FosterHome
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome
BEFORE INSERT ON FosterHome
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', NULL, NULL,                           
        NULL, TO_CHAR(NEW.idFosterHome), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome
BEFORE UPDATE ON FosterHome
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FosterHome', 'idLocation',
            TO_CHAR(OLD.idLocation), TO_CHAR(NEW.idLocation),
            TO_CHAR(NEW.idFosterHome), 'Changed associated location', CURRENT_USER()
        );
    END IF;

    IF OLD.idFosterHomeStatus != NEW.idFosterHomeStatus THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FosterHome', 'idFosterHomeStatus',
            TO_CHAR(OLD.idFosterHomeStatus), TO_CHAR(NEW.idFosterHomeStatus),
            TO_CHAR(NEW.idFosterHome), 'Changed status of foster home', CURRENT_USER()
        );
    END IF;

    IF OLD.maxCapacity != NEW.maxCapacity THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FosterHome', 'maxCapacity',
            TO_CHAR(OLD.maxCapacity), TO_CHAR(NEW.maxCapacity),
            TO_CHAR(NEW.idFosterHome), 'Changed max capacity', CURRENT_USER()
        );
    END IF;

    IF OLD.requiresFoodDonation != NEW.requiresFoodDonation THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FosterHome', 'requiresFoodDonation',
            TO_CHAR(OLD.requiresFoodDonation), TO_CHAR(NEW.requiresFoodDonation),
            TO_CHAR(NEW.idFosterHome), 'Changed food donation requirement', CURRENT_USER()
        );
    END IF;

    IF OLD.petCount != NEW.petCount THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FosterHome', 'petCount',
            TO_CHAR(OLD.petCount), TO_CHAR(NEW.petCount),
            TO_CHAR(NEW.idFosterHome), 'Changed current pet count', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteFosterHome
BEFORE DELETE ON FosterHome
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome', NULL, NULL,
        NULL, TO_CHAR(OLD.idFosterHome), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FosterHome_x_petSize
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome_x_petSize
BEFORE INSERT ON FosterHome_x_petSize
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL,                           
        NULL, TO_CHAR(NEW.idFosterHome) || '-' || TO_CHAR(NEW.idPetSize),
        'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome_x_petSize
BEFORE UPDATE ON FosterHome_x_petSize
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforDeleteFosterHome_x_petSize
BEFORE DELETE ON FosterHome_x_petSize
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petSize', NULL, NULL,                           
        NULL, TO_CHAR(OLD.idFosterHome) || '-' || TO_CHAR(OLD.idPetSize),
        'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FosterHome_x_petType
DELIMITER //
CREATE TRIGGER beforeInsertFosterHome_x_petType
BEFORE INSERT ON FosterHome_x_petType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL,                           
        NULL, TO_CHAR(NEW.idFosterHome) || '-' || TO_CHAR(NEW.idPetType),
        'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateFosterHome_x_petType
BEFORE UPDATE ON FosterHome_x_petType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforDeleteFosterHome_x_petType
BEFORE DELETE ON FosterHome_x_petType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FosterHome_x_petType', NULL, NULL,                           
        NULL, TO_CHAR(OLD.idFosterHome) || '-' || TO_CHAR(OLD.idPetType),
        'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;
-- ================================================
-- Triggers tablas House, Adopter y adoption
-- ================================================
-- HouseType
DELIMITER //
CREATE TRIGGER beforeInsertHouseType
BEFORE INSERT ON HouseType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'HouseType', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateHouseType
BEFORE UPDATE ON HouseType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'HouseType', 'name',
            TO_CHAR(OLD.name), TO_CHAR(NEW.name),
            TO_CHAR(NEW.id), 'Changed house type name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteHouseType
BEFORE DELETE ON HouseType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'HouseType', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- House
DELIMITER //
CREATE TRIGGER beforeInsertHouse
BEFORE INSERT ON House
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateHouse
BEFORE UPDATE ON House
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idHouseType != NEW.idHouseType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'House', 'idHouseType',
            TO_CHAR(OLD.idHouseType), TO_CHAR(NEW.idHouseType),
            TO_CHAR(NEW.id), 'Changed associated house type', CURRENT_USER()
        );
    END IF;

    IF OLD.hasYard != NEW.hasYard THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'House', 'hasYard',
            TO_CHAR(OLD.hasYard), TO_CHAR(NEW.hasYard),
            TO_CHAR(NEW.id), 'Changed yard availability flag', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteHouse
BEFORE DELETE ON HouseType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'House', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;



-- ExerciseTime
DELIMITER //
CREATE TRIGGER beforeInsertExerciseTime
BEFORE INSERT ON ExerciseTime
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ExerciseTime', NULL, NULL,                           
        NULL, TO_CHAR(NEW.id), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateExerciseTime
BEFORE UPDATE ON ExerciseTime
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.value != NEW.value THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'ExerciseTime', 'value',
            TO_CHAR(OLD.value), TO_CHAR(NEW.value),
            TO_CHAR(NEW.id), 'Changed exercise time value', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteExerciseTime
BEFORE DELETE ON ExerciseTime
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'ExerciseTime', NULL, NULL,
        NULL, TO_CHAR(OLD.id), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- Adopter 
DELIMITER //
CREATE TRIGGER beforeInsertAdopter
BEFORE INSERT ON Adopter
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', NULL, NULL,                           
        NULL, TO_CHAR(NEW.idAdopter), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateAdopter
BEFORE UPDATE ON Adopter
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idHouse != NEW.idHouse THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adopter', 'idHouse',
            TO_CHAR(OLD.idHouse), TO_CHAR(NEW.idHouse),
            TO_CHAR(NEW.idAdopter), 'Changed associated house', CURRENT_USER()
        );
    END IF;

    IF OLD.idExerciseTime != NEW.idExerciseTime THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adopter', 'idExerciseTime',
            TO_CHAR(OLD.idExerciseTime), TO_CHAR(NEW.idExerciseTime),
            TO_CHAR(NEW.idAdopter), 'Changed exercise time', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteAdopter
BEFORE DELETE ON Adopter
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adopter', NULL, NULL,
        NULL, TO_CHAR(OLD.idAdopter), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- OtherPet
DELIMITER //
CREATE TRIGGER beforeInsertOtherPet
BEFORE INSERT ON OtherPet
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateOtherPet
BEFORE UPDATE ON OtherPet
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPetBreed != NEW.idPetBreed THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'OtherPet', 'idPetBreed',
            OLD.idPetBreed, NEW.idPetBreed,
            NEW.id, 'Changed associated pet breed', CURRENT_USER()
        );
    END IF;

    IF OLD.idAdopter != NEW.idAdopter THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'OtherPet', 'idAdopter',
            OLD.idAdopter, NEW.idAdopter,
            NEW.id, 'Changed associated adopter', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteOtherPet
BEFORE DELETE ON OtherPet
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'OtherPet', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Adoption
DELIMITER //
CREATE TRIGGER beforeInsertAdoption
BEFORE INSERT ON Adoption
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateAdoption
BEFORE UPDATE ON Adoption
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adoption', 'idPerson',
            OLD.idPerson, NEW.idPerson,
            NEW.id, 'Changed associated person', CURRENT_USER()
        );
    END IF;

    IF OLD.idAdopter != NEW.idAdopter THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adoption', 'idAdopter',
            OLD.idAdopter, NEW.idAdopter,
            NEW.id, 'Changed associated adopter', CURRENT_USER()
        );
    END IF;

    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adoption', 'idPet',
            OLD.idPet, NEW.idPet,
            NEW.id, 'Changed associated pet', CURRENT_USER()
        );
    END IF;

    IF OLD.adoptionDate != NEW.adoptionDate THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Adoption', 'adoptionDate',
            OLD.adoptionDate, NEW.adoptionDate,
            NEW.id, 'Changed adoption date', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteAdoption
BEFORE DELETE ON Adoption
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Adoption', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- FollowUp
DELIMITER //
CREATE TRIGGER beforeInsertFollowUp
BEFORE INSERT ON FollowUp
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateFollowUp
BEFORE UPDATE ON FollowUp
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idAdoption != NEW.idAdoption THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FollowUp', 'idAdoption',
            OLD.idAdoption, NEW.idAdoption,
            NEW.id, 'Changed associated adoption', CURRENT_USER()
        );
    END IF;

    IF OLD.comments != NEW.comments THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FollowUp', 'comments',
            OLD.comments, NEW.comments,
            NEW.id, 'Changed comments', CURRENT_USER()
        );
    END IF;

    IF OLD.followUpDate != NEW.followUpDate THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'FollowUp', 'followUpDate',
            OLD.followUpDate, NEW.followUpDate,
            NEW.id, 'Changed follow-up date', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteFollowUp
BEFORE DELETE ON FollowUp
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'FollowUp', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetOwnerRating
DELIMITER //
CREATE TRIGGER beforeInsertPetOwnerRating
BEFORE INSERT ON PetOwnerRating
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetOwnerRating
BEFORE UPDATE ON PetOwnerRating
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idAdoption != NEW.idAdoption THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetOwnerRating', 'idAdoption',
            OLD.idAdoption, NEW.idAdoption,
            NEW.id, 'Changed associated adoption', CURRENT_USER()
        );
    END IF;

    IF OLD.rating != NEW.rating THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetOwnerRating', 'rating',
            OLD.rating, NEW.rating,
            NEW.id, 'Changed rating score', CURRENT_USER()
        );
    END IF;

    IF OLD.notes != NEW.notes THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetOwnerRating', 'notes',
            OLD.notes, NEW.notes,
            NEW.id, 'Changed rating notes', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetOwnerRating
BEFORE DELETE ON PetOwnerRating
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetOwnerRating', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- ================================================
-- ==== Triggers tablas relacionadas a Photo ====
-- ================================================

-- PhotoType
DELIMITER //
CREATE TRIGGER beforeInsertPhotoType
BEFORE INSERT ON PhotoType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PhotoType', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePhotoType
BEFORE UPDATE ON PhotoType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PhotoType', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed photo type name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePhotoType
BEFORE DELETE ON PhotoType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PhotoType', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Photo
DELIMITER //
CREATE TRIGGER beforeInsertPhoto
BEFORE INSERT ON Photo
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePhoto
BEFORE UPDATE ON Photo
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idFollowUp != NEW.idFollowUp THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Photo', 'idFollowUp',
            OLD.idFollowUp, NEW.idFollowUp,
            NEW.id, 'Changed associated follow-up', CURRENT_USER()
        );
    END IF;

    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Photo', 'idPet',
            OLD.idPet, NEW.idPet,
            NEW.id, 'Changed associated pet', CURRENT_USER()
        );
    END IF;

    IF OLD.idPhotoType != NEW.idPhotoType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Photo', 'idPhotoType',
            OLD.idPhotoType, NEW.idPhotoType,
            NEW.id, 'Changed associated photo type', CURRENT_USER()
        );
    END IF;

    IF OLD.photoURL != NEW.photoURL THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Photo', 'photoURL',
            OLD.photoURL, NEW.photoURL,
            NEW.id, 'Changed photo URL', CURRENT_USER()
        );
    END IF;

    IF OLD.uploadDate != NEW.uploadDate THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Photo', 'uploadDate',
            OLD.uploadDate, NEW.uploadDate,
            NEW.id, 'Changed photo upload date', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePhoto
BEFORE DELETE ON Photo
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Photo', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;


-- =======================================================
-- ==== Triggers tablas de enfermedades y veterinario ====       
-- =======================================================

-- Veterinarian
DELIMITER //
CREATE TRIGGER beforeInsertVeterinarian
BEFORE INSERT ON Veterinarian
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Veterinarian', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateVeterinarian
BEFORE UPDATE ON Veterinarian
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Veterinarian', 'idPerson',
            OLD.idPerson, NEW.idPerson,
            NEW.id, 'Changed associated person', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteVeterinarian
BEFORE DELETE ON Veterinarian
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Veterinarian', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Disease
DELIMITER //
CREATE TRIGGER beforeInsertDisease
BEFORE INSERT ON Disease
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDisease
BEFORE UPDATE ON Disease
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Disease', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed disease name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteDisease
BEFORE DELETE ON Disease
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Disease_x_pet
DELIMITER //
CREATE TRIGGER beforeInsertDiseaseXPet
BEFORE INSERT ON Disease_x_pet
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease_x_pet', NULL, NULL,
        NULL, CONCAT(NEW.idDisease, '-', NEW.idPet), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateDiseaseXPet
BEFORE UPDATE ON Disease_x_pet
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteDiseaseXPet
BEFORE DELETE ON Disease_x_pet
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Disease_x_pet', NULL, NULL,
        NULL, CONCAT(OLD.idDisease, '-', OLD.idPet), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Treatment
DELIMITER //
CREATE TRIGGER beforeInsertTreatment
BEFORE INSERT ON Treatment
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateTreatment
BEFORE UPDATE ON Treatment
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Treatment', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed treatment name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteTreatment
BEFORE DELETE ON Treatment
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Treatment_x_disease
DELIMITER //
CREATE TRIGGER beforeInsertTreatmentXDisease
BEFORE INSERT ON Treatment_x_disease
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment_x_disease', NULL, NULL,
        NULL, CONCAT(NEW.idDisease, '-', NEW.idTreatment), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateTreatmentXDisease
BEFORE UPDATE ON Treatment_x_disease
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.timeLength != NEW.timeLength THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Treatment_x_disease', 'timeLength',
            OLD.timeLength, NEW.timeLength,
            CONCAT(NEW.idDisease, '-', NEW.idTreatment), 'Changed treatment time length', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteTreatmentXDisease
BEFORE DELETE ON Treatment_x_disease
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Treatment_x_disease', NULL, NULL,
        NULL, CONCAT(OLD.idDisease, '-', OLD.idTreatment), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Medication
DELIMITER //
CREATE TRIGGER beforeInsertMedication
BEFORE INSERT ON Medication
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateMedication
BEFORE UPDATE ON Medication
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Medication', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed medication name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteMedication
BEFORE DELETE ON Medication
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Medication_x_treatment
DELIMITER //
CREATE TRIGGER beforeInsertMedicationXTreatment
BEFORE INSERT ON Medication_x_treatment
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication_x_treatment', NULL, NULL,
        NULL, CONCAT(NEW.idMedication, '-', NEW.idTreatment), 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateMedicationXTreatment
BEFORE UPDATE ON Medication_x_treatment
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.dosage != NEW.dosage THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Medication_x_treatment', 'dosage',
            OLD.dosage, NEW.dosage,
            CONCAT(NEW.idMedication, '-', NEW.idTreatment), 'Changed medication dosage', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteMedicationXTreatment
BEFORE DELETE ON Medication_x_treatment
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Medication_x_treatment', NULL, NULL,
        NULL, CONCAT(OLD.idMedication, '-', OLD.idTreatment), 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- ==== Triggers tablas Pet ====                
-- ================================================

-- PetType
DELIMITER //
CREATE TRIGGER beforeInsertPetType
BEFORE INSERT ON PetType
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetType', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetType
BEFORE UPDATE ON PetType
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetType', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet type name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetType
BEFORE DELETE ON PetType
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetType', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetBreed
DELIMITER //
CREATE TRIGGER beforeInsertPetBreed
BEFORE INSERT ON PetBreed
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetBreed
BEFORE UPDATE ON PetBreed
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetBreed', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed breed name', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetType != NEW.idPetType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetBreed', 'idPetType',
            OLD.idPetType, NEW.idPetType,
            NEW.id, 'Changed associated pet type', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetBreed
BEFORE DELETE ON PetBreed
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetBreed', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetSize
DELIMITER //
CREATE TRIGGER beforeInsertPetSize
BEFORE INSERT ON PetSize
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSize', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetSize
BEFORE UPDATE ON PetSize
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetSize', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet size name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetSize
BEFORE DELETE ON PetSize
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSize', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetColor
DELIMITER //
CREATE TRIGGER beforeInsertPetColor
BEFORE INSERT ON PetColor
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetColor', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetColor
BEFORE UPDATE ON PetColor
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetColor', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet color name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetColor
BEFORE DELETE ON PetColor
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetColor', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetSeverity
DELIMITER //
CREATE TRIGGER beforeInsertPetSeverity
BEFORE INSERT ON PetSeverity
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSeverity', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetSeverity
BEFORE UPDATE ON PetSeverity
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetSeverity', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet severity name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetSeverity
BEFORE DELETE ON PetSeverity
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetSeverity', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetEnergy
DELIMITER //
CREATE TRIGGER beforeInsertPetEnergy
BEFORE INSERT ON PetEnergy
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetEnergy', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetEnergy
BEFORE UPDATE ON PetEnergy
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetEnergy', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet energy name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetEnergy
BEFORE DELETE ON PetEnergy
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetEnergy', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetTrainability
DELIMITER //
CREATE TRIGGER beforeInsertPetTrainability
BEFORE INSERT ON PetTrainability
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetTrainability', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetTrainability
BEFORE UPDATE ON PetTrainability
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetTrainability', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet trainability name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetTrainability
BEFORE DELETE ON PetTrainability
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetTrainability', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- PetStatus
DELIMITER //
CREATE TRIGGER beforeInsertPetStatus
BEFORE INSERT ON PetStatus
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetStatus', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePetStatus
BEFORE UPDATE ON PetStatus
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'PetStatus', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet status name', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePetStatus
BEFORE DELETE ON PetStatus
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'PetStatus', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Pet
DELIMITER //
CREATE TRIGGER beforeInsertPet
BEFORE INSERT ON Pet
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdatePet
BEFORE UPDATE ON Pet
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idLocation != NEW.idLocation THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idLocation',
            OLD.idLocation, NEW.idLocation,
            NEW.id, 'Changed pet location', CURRENT_USER()
        );
    END IF;

    IF OLD.idPerson != NEW.idPerson THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPerson',
            OLD.idPerson, NEW.idPerson,
            NEW.id, 'Changed associated person', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetBreed != NEW.idPetBreed THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetBreed',
            OLD.idPetBreed, NEW.idPetBreed,
            NEW.id, 'Changed breed', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetSize != NEW.idPetSize THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetSize',
            OLD.idPetSize, NEW.idPetSize,
            NEW.id, 'Changed size', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetColor != NEW.idPetColor THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetColor',
            OLD.idPetColor, NEW.idPetColor,
            NEW.id, 'Changed color', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetSeverity != NEW.idPetSeverity THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetSeverity',
            OLD.idPetSeverity, NEW.idPetSeverity,
            NEW.id, 'Changed severity', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetEnergy != NEW.idPetEnergy THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetEnergy',
            OLD.idPetEnergy, NEW.idPetEnergy,
            NEW.id, 'Changed energy level', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetTrainability != NEW.idPetTrainability THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetTrainability',
            OLD.idPetTrainability, NEW.idPetTrainability,
            NEW.id, 'Changed trainability level', CURRENT_USER()
        );
    END IF;

    IF OLD.idPetStatus != NEW.idPetStatus THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idPetStatus',
            OLD.idPetStatus, NEW.idPetStatus,
            NEW.id, 'Changed pet status', CURRENT_USER()
        );
    END IF;

    IF OLD.idVeterinarian != NEW.idVeterinarian THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'idVeterinarian',
            OLD.idVeterinarian, NEW.idVeterinarian,
            NEW.id, 'Changed veterinarian', CURRENT_USER()
        );
    END IF;

    IF OLD.chipId != NEW.chipId THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'chipId',
            OLD.chipId, NEW.chipId,
            NEW.id, 'Changed chip ID', CURRENT_USER()
        );
    END IF;

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed pet name', CURRENT_USER()
        );
    END IF;

    IF OLD.requiresSpace != NEW.requiresSpace THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'requiresSpace',
            OLD.requiresSpace, NEW.requiresSpace,
            NEW.id, 'Changed space requirement', CURRENT_USER()
        );
    END IF;

    IF OLD.estimatedAge != NEW.estimatedAge THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Pet', 'estimatedAge',
            OLD.estimatedAge, NEW.estimatedAge,
            NEW.id, 'Changed estimated age', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeletePet
BEFORE DELETE ON Pet
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Pet', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- ================================================
-- ==== Triggers recompensa y parametros ====
-- ================================================

-- Reward
DELIMITER //
CREATE TRIGGER beforeInsertReward
BEFORE INSERT ON Reward
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateReward
BEFORE UPDATE ON Reward
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.idPet != NEW.idPet THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Reward', 'idPet',
            OLD.idPet, NEW.idPet,
            NEW.id, 'Changed associated pet', CURRENT_USER()
        );
    END IF;

    IF OLD.idCurrencyType != NEW.idCurrencyType THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Reward', 'idCurrencyType',
            OLD.idCurrencyType, NEW.idCurrencyType,
            NEW.id, 'Changed currency type', CURRENT_USER()
        );
    END IF;

    IF OLD.amount != NEW.amount THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Reward', 'amount',
            OLD.amount, NEW.amount,
            NEW.id, 'Changed reward amount', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteReward
BEFORE DELETE ON Reward
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Reward', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;

-- Parameter
DELIMITER //
CREATE TRIGGER beforeInsertParameter
BEFORE INSERT ON Parameter
FOR EACH ROW
BEGIN
    SET NEW.creationDate = CURRENT_TIMESTAMP, NEW.createdBy = CURRENT_USER();

    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', NULL, NULL,
        NULL, NEW.id, 'New tuple insertion', CURRENT_USER());
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeUpdateParameter
BEFORE UPDATE ON Parameter
FOR EACH ROW
BEGIN
    SET NEW.updatedDate = CURRENT_TIMESTAMP, NEW.updatedBy = CURRENT_USER();

    IF OLD.description != NEW.description THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Parameter', 'description',
            OLD.description, NEW.description,
            NEW.id, 'Changed parameter description', CURRENT_USER()
        );
    END IF;

    IF OLD.name != NEW.name THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Parameter', 'name',
            OLD.name, NEW.name,
            NEW.id, 'Changed parameter name', CURRENT_USER()
        );
    END IF;

    IF OLD.textValue != NEW.textValue THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Parameter', 'textValue',
            OLD.textValue, NEW.textValue,
            NEW.id, 'Changed parameter text value', CURRENT_USER()
        );
    END IF;

    IF OLD.numberValue != NEW.numberValue THEN
        CALL ADOPCION_AUDIT.CreateLog(
            'ADOPCION_APP', 'Parameter', 'value',
            OLD.numberValue, NEW.numberValue,
            NEW.id, 'Changed parameter number value', CURRENT_USER()
        );
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER beforeDeleteParameter
BEFORE DELETE ON Parameter
FOR EACH ROW
BEGIN
    CALL ADOPCION_AUDIT.CreateLog('ADOPCION_APP', 'Parameter', NULL, NULL,
        NULL, OLD.id, 'Tuple deletion', CURRENT_USER());
END;//
DELIMITER ;