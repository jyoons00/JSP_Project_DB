-- (��-> �Ʒ� ������ ����)

-- �������ν����� �ο��� ��ȣ �κо� �巡�� �ؼ� ����
-- ctrl + ENTER

-- ���ν��� ���๮�� �ǹر��� �巡�� �ؼ� 
-- ctrl + ENTER

-- ��ٱ��� ������ ����
CREATE SEQUENCE SEQ_CART
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- ��ٱ��� ��� ������ ����
CREATE SEQUENCE SEQ_CARTLIST
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


-- 0) ��ǰ���� ������ ���ν���
create or replace PROCEDURE get_productinfo
(
    pPDT_ID IN O_PRODUCT.PDT_ID%TYPE
)
IS
    vPDT_NAME O_PRODUCT.PDT_NAME%TYPE;
    vPDT_AMOUNT O_PRODUCT.PDT_AMOUNT%TYPE;
    vPDT_DISCOUNT_RATE O_PRODUCT.PDT_DISCOUNT_RATE%TYPE;
    vDiscounted_Amount NUMBER;
BEGIN
    -- ��ǰ ������ �������� SELECT ��
    SELECT PDT_NAME, PDT_AMOUNT, PDT_DISCOUNT_RATE 
    INTO vPDT_NAME, vPDT_AMOUNT, vPDT_DISCOUNT_RATE
    FROM O_PRODUCT
    WHERE PDT_ID = pPDT_ID;

    -- NULL ó�� �� ���� ���� ���
    vPDT_AMOUNT := NVL(vPDT_AMOUNT, 0);
    vPDT_DISCOUNT_RATE := NVL(vPDT_DISCOUNT_RATE, 0);
    vDiscounted_Amount := ROUND(vPDT_AMOUNT * (1 - vPDT_DISCOUNT_RATE/100), 2);

    -- ��� ���
    DBMS_OUTPUT.PUT_LINE('��ǰ��: ' || vPDT_NAME);
    DBMS_OUTPUT.PUT_LINE('����: ' || vPDT_AMOUNT);
    DBMS_OUTPUT.PUT_LINE('���ΰ�: ' || vDiscounted_Amount);

--EXCEPTION
END;



-- 1) ��ٱ��� (��ǰ �߰�) 
CREATE OR REPLACE PROCEDURE UP_CARTLIST_ADD (
    PUSER_ID IN NUMBER,  -- ȸ��ID   
    PPDT_ID IN NUMBER,   -- ��ǰID
    POPT_ID IN NUMBER,   -- �ɼ�ID
    PQUANTITY IN NUMBER  -- ����
) AS
    VCART_ID NUMBER;        
    VEXISTING_COUNT NUMBER;
    VOPTION_EXISTS NUMBER;  
    VVALID_OPTION NUMBER;
    VSTOCK_QUANTITY NUMBER;
BEGIN
    BEGIN
        -- ��ٱ��� ID ��������
        SELECT CART_ID
        INTO VCART_ID
        FROM O_CART
        WHERE USER_ID = PUSER_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- ��ٱ��ϰ� �������� ���� ��� ��ٱ��� ����
            INSERT INTO O_CART (CART_ID, USER_ID)
            VALUES (SEQ_CART.NEXTVAL, PUSER_ID);
    END;

    BEGIN
        -- �ɼ��� �����ϴ��� Ȯ��
        SELECT COUNT(*)
        INTO VOPTION_EXISTS
        FROM O_PDTOPTION
        WHERE PDT_ID = PPDT_ID;

        IF VOPTION_EXISTS > 0 THEN
            -- �ɼ��� �ʿ��ϴ� ��ǰ�ε� �ɼ��� �������� ���� ���
            IF POPT_ID IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('�ش� ��ǰ�� �ʼ� �ɼ��� �ʿ��մϴ�. �ɼ��� �����ؾ� �մϴ�.');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
                RETURN;
            END IF;

            -- ������ �ɼ� ID�� ��ȿ���� Ȯ��
            SELECT COUNT(*)
            INTO VVALID_OPTION
            FROM O_PDTOPTION
            WHERE PDT_ID = PPDT_ID
            AND OPT_ID = POPT_ID;

            IF VVALID_OPTION = 0 THEN
                DBMS_OUTPUT.PUT_LINE('�ش� ��ǰ������ �������� �ʴ� �ɼ��Դϴ�. �ùٸ� �ɼ��� �����Ͻʽÿ�.');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
                RETURN;
            END IF;

        ELSE
            -- �ɼ��� �ʿ� ���� ��ǰ�ε� �ɼ��� ������ ���
            IF POPT_ID IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('�ش� ��ǰ�� �ɼ��� �ʿ����� �ʽ��ϴ�.');
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
                RETURN;
            END IF;
        END IF;

        -- ��� ���� Ȯ��
        SELECT NVL(p.PDT_COUNT - NVL(cl.CLIST_PDT_COUNT, 0), p.PDT_COUNT)
        INTO VSTOCK_QUANTITY
        FROM O_PRODUCT p
        LEFT JOIN O_CARTLIST cl ON p.PDT_ID = cl.PDT_ID AND cl.OPT_ID = POPT_ID
        WHERE p.PDT_ID = PPDT_ID;

        -- ���� ��ٱ��Ͽ��� ��ǰ ���� �հ� ���
        IF VSTOCK_QUANTITY < PQUANTITY THEN
            DBMS_OUTPUT.PUT_LINE('��� �����մϴ�. ���� ��� ����: ' || VSTOCK_QUANTITY);
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            RETURN;
        END IF;

        -- ��ٱ��Ͽ� ���� ��ǰ�� �ɼ��� �̹� �ִ��� Ȯ��
        SELECT COUNT(*)
        INTO VEXISTING_COUNT
        FROM O_CARTLIST
        WHERE CART_ID = VCART_ID
        AND PDT_ID = PPDT_ID
        AND NVL(OPT_ID, 0) = NVL(POPT_ID, 0);  -- �ɼ� ID ��, NULL ó��

        IF VEXISTING_COUNT > 0 THEN
            -- ���� ��ǰ�� �ɼ��� ���� ��� ���� ����
            UPDATE O_CARTLIST
            SET CLIST_PDT_COUNT = CLIST_PDT_COUNT + PQUANTITY
            WHERE CART_ID = VCART_ID
            AND PDT_ID = PPDT_ID
            AND NVL(OPT_ID, 0) = NVL(POPT_ID, 0);  -- �ɼ� ID ��, NULL ó��

            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� ������ ��ǰ�� �ֽ��ϴ�. ������ ����Ǿ����ϴ�.');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
        ELSE
            -- ���ο� ��ǰ�� �ɼ� �߰�
            INSERT INTO O_CARTLIST (
                CLIST_ID, CART_ID, PDT_ID, OPT_ID, CLIST_PDT_COUNT, CLIST_ADDDATE
            )
            VALUES (
                SEQ_CARTLIST.NEXTVAL, VCART_ID, PPDT_ID, POPT_ID, PQUANTITY, SYSDATE
            );

            DBMS_OUTPUT.PUT_LINE('��ǰ�� ��ٱ��Ͽ� �߰��Ǿ����ϴ�.');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('��ǰ�� ��ٱ��Ͽ� �߰��ϴ� �� ������ �߻��߽��ϴ�. ���� �޽���: ' || SQLERRM);
    END;
END;







-- 2) ��ٱ��� ��� (���� ����) 
CREATE OR REPLACE PROCEDURE UP_CARTLIST_PRICE (
    PUSER_ID IN NUMBER
) AS
    VCART_ID NUMBER;
    VTOTAL_AMOUNT NUMBER := 0;  -- �� ��ǰ �ݾ� (���� ��)
    VTOTAL_ITEMS NUMBER := 0;  -- �� ��ǰ ����
    VDELIVERY_FEE NUMBER := 0;  -- ��ۺ�
    VDISCOUNT_AMOUNT NUMBER := 0;  -- �� ���� �ݾ�
    VFINAL_AMOUNT NUMBER := 0;  -- �� ���� ���� �ݾ�
    VADDITIONAL_AMOUNT NUMBER := 0; -- �߰� ���Ž� �����۱��� ���� �ݾ�
    VPRODUCT_COUNT NUMBER := 0; -- ��ǰ �� (�ɼ� ����)
BEGIN
    BEGIN
        -- ��ٱ��� ID ��������
        SELECT CART_ID
        INTO VCART_ID
        FROM O_CART
        WHERE USER_ID = PUSER_ID;

        BEGIN
            -- �� ��ǰ �ݾ�, ���� �ݾ�, �� ��ǰ ���� ��� (�ɼ� ����)
            SELECT 
                NVL(SUM((P.PDT_AMOUNT + NVL(PO.OPT_AMOUNT, 0)) * CL.CLIST_PDT_COUNT), 0) AS TOTAL_AMOUNT,
                NVL(SUM(P.PDT_AMOUNT * CL.CLIST_PDT_COUNT * (P.PDT_DISCOUNT_RATE / 100)), 0) AS DISCOUNT_AMOUNT,
                NVL(COUNT(*), 0) AS PRODUCT_COUNT
            INTO VTOTAL_AMOUNT, VDISCOUNT_AMOUNT, VPRODUCT_COUNT
            FROM O_CARTLIST CL
            JOIN O_PRODUCT P ON CL.PDT_ID = P.PDT_ID
            LEFT JOIN O_PDTOPTION PO ON CL.OPT_ID = PO.OPT_ID
            WHERE CL.CART_ID = VCART_ID
            AND CL.CLIST_SELECT = 'Y';  -- ���õ� ��ǰ�� ����

            -- ��ǰ�� ������ ������� �ʱ�
            IF VPRODUCT_COUNT = 0 THEN
                DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� ���õ� ��ǰ�� ������� �ʽ��ϴ�.');
                DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
                DBMS_OUTPUT.PUT_LINE('');
                RETURN;
            END IF;

            -- �� ���� �ݾ׿��� ���� �ݾ� ����
            VTOTAL_AMOUNT := VTOTAL_AMOUNT - VDISCOUNT_AMOUNT;

            -- ��ۺ� ���
            IF VTOTAL_AMOUNT >= 50000 THEN
                VDELIVERY_FEE := 0;
            ELSE
                VDELIVERY_FEE := 3000;
                VADDITIONAL_AMOUNT := 50000 - VTOTAL_AMOUNT;
            END IF;

            -- �� ���� ���� �ݾ� ���
            VFINAL_AMOUNT := VTOTAL_AMOUNT + VDELIVERY_FEE;

            -- ��� �޽���
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('�� ��ǰ�ݾ�: ' || (VTOTAL_AMOUNT + VDISCOUNT_AMOUNT) || '��');
            DBMS_OUTPUT.PUT_LINE('��ǰ���αݾ�: -' || VDISCOUNT_AMOUNT || '��');
            DBMS_OUTPUT.PUT_LINE('�� ��ۺ�: ' || VDELIVERY_FEE || '��');
            
            IF VADDITIONAL_AMOUNT > 0 THEN
                DBMS_OUTPUT.PUT_LINE(VADDITIONAL_AMOUNT || '�� �߰� ���Ž� ������');
            END IF;

            DBMS_OUTPUT.PUT_LINE('�� ���������ݾ�: ' || VFINAL_AMOUNT || '��');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
             
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� ���õ� ��ǰ�� ������� �ʽ��ϴ�.');
        END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('��ٱ��ϰ� �������� �ʽ��ϴ�.');
    END;
END;








-- 3) ��ٱ��� (��ǰ ��ȸ) 
CREATE OR REPLACE PROCEDURE UP_CART_CHECK (
    PUSER_ID NUMBER
) IS  
    VCART_COUNT NUMBER; -- ��ٱ��� ���� ����
    VCLIST_COUNT NUMBER; -- ��ٱ��Ͽ� ���õ� ��ǰ ����
BEGIN
    -- ��ٱ��� ���� ���� Ȯ��
    SELECT COUNT(*)
    INTO VCART_COUNT
    FROM O_CART
    WHERE USER_ID = PUSER_ID;
    
    IF VCART_COUNT = 0 THEN 
        DBMS_OUTPUT.PUT_LINE('��ٱ��ϰ� �������� �ʽ��ϴ�.');
        RETURN;
    END IF;
    
    -- ��ٱ��Ͽ� ��� ��ǰ ���� Ȯ�� (���õ� ��ǰ��)
    SELECT COUNT(*)
    INTO VCLIST_COUNT
    FROM O_CARTLIST
    WHERE CART_ID IN (
        SELECT CART_ID 
        FROM O_CART 
        WHERE USER_ID = PUSER_ID
    )
    AND CLIST_SELECT = 'Y';  -- ���õ� ��ǰ�� ����

    IF VCLIST_COUNT = 0 THEN 
        DBMS_OUTPUT.PUT_LINE('���õ� ��ǰ�� ������� �ʽ��ϴ�.');  
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('��ü��ǰ(' || VCLIST_COUNT || ')');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('���õ� ��ǰ�� ��� �ֽ��ϴ�.');  
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('��ü��ǰ(' || VCLIST_COUNT || ')');
        
        -- ��ǰ��� ���� ��� (���õ� ��ǰ��)
        FOR ACUR IN (
            SELECT 
                P.PDT_NAME, 
                NVL(PO.OPT_NAME, NULL) AS OPT_NAME, 
                CL.CLIST_PDT_COUNT
            FROM O_CARTLIST CL
            JOIN O_PRODUCT P ON CL.PDT_ID = P.PDT_ID
            LEFT JOIN O_PDTOPTION PO ON CL.OPT_ID = PO.OPT_ID
            WHERE CL.CART_ID IN (
                SELECT CART_ID 
                FROM O_CART 
                WHERE USER_ID = PUSER_ID
            )
            AND CL.CLIST_SELECT = 'Y'  -- ���õ� ��ǰ�� ����
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                '��ǰ��: ' || ACUR.PDT_NAME || 
                CASE
                    WHEN ACUR.OPT_NAME IS NOT NULL THEN
                        ', �ɼ�: ' || ACUR.OPT_NAME
                    ELSE 
                        ''
                END || ', ����: ' || ACUR.CLIST_PDT_COUNT
            );
        END LOOP;
    END IF;
END;









-- 4) ��ٱ��� ��� (���� ����)
CREATE OR REPLACE PROCEDURE UP_CARTLIST_UPDATE (
    PUSER_ID IN NUMBER,
    PPDT_ID IN NUMBER,
    PUPDATE_MODE IN NUMBER  -- 1�̸� ����, -1�̸� ����
) AS
    VCART_ID NUMBER;
    VEXISTING_COUNT NUMBER;
    VNEW_QUANTITY NUMBER;
    VSTOCK_QUANTITY NUMBER;
BEGIN
    -- ��ٱ��� ID ��������
    SELECT CART_ID
    INTO VCART_ID
    FROM O_CART
    WHERE USER_ID = PUSER_ID;

    BEGIN
        -- ��� ���� Ȯ��
        SELECT p.PDT_COUNT
        INTO VSTOCK_QUANTITY
        FROM O_PRODUCT p
        WHERE p.PDT_ID = PPDT_ID;

        -- ��ٱ��Ͽ� ���� ��ǰ�� �̹� �ִ��� Ȯ��
        SELECT CLIST_PDT_COUNT
        INTO VEXISTING_COUNT
        FROM O_CARTLIST
        WHERE CART_ID = VCART_ID
        AND PDT_ID = PPDT_ID;
 
        -- ���ο� ���� ���
        VNEW_QUANTITY := VEXISTING_COUNT + PUPDATE_MODE;

        -- ������ 1 ���Ϸ� �������� �ʵ��� ����
        IF VNEW_QUANTITY < 1 THEN
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('������ 1 �̻��̾�� �մϴ�.');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            RETURN;
        END IF;

        -- ��� ������� ���� ��� ó��
        IF VNEW_QUANTITY > VSTOCK_QUANTITY THEN
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('��� �����մϴ�. ���� ��� ����: ' || VSTOCK_QUANTITY);
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            RETURN;
        END IF;

        -- ���� ��ǰ�� ���� ��� ���� ������Ʈ
        UPDATE O_CARTLIST
        SET CLIST_PDT_COUNT = VNEW_QUANTITY 
        WHERE CART_ID = VCART_ID
        AND PDT_ID = PPDT_ID;

        DBMS_OUTPUT.PUT_LINE('������ ����Ǿ����ϴ�.');

        -- ��ٱ��� ���¿� ������ ������Ʈ�ϴ� ���ν��� ȣ��
        UP_CART_CHECK(PUSER_ID);
        UP_CARTLIST_PRICE(PUSER_ID);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� �ش� ��ǰ�� �������� �ʽ��ϴ�.');
    END;
END;








-- 5) ��ٱ��� ��� (���� ����)
CREATE OR REPLACE PROCEDURE UP_CARTLIST_SELECT (
    PUSER_ID IN NUMBER,
    PPDT_ID IN NUMBER,
    PSELECT IN CHAR
) AS
    VCART_ID NUMBER;
    VEXISTING_COUNT NUMBER;
BEGIN
    -- ��ٱ��� ID ��������
    SELECT CART_ID
    INTO VCART_ID
    FROM O_CART
    WHERE USER_ID = PUSER_ID;

    BEGIN
        -- ��ٱ��Ͽ� ���� ��ǰ�� �̹� �ִ��� Ȯ��
        SELECT COUNT(*)
        INTO VEXISTING_COUNT
        FROM O_CARTLIST
        WHERE CART_ID = VCART_ID
        AND PDT_ID = PPDT_ID;

        IF VEXISTING_COUNT > 0 THEN
            -- ���� ���� ������Ʈ
            UPDATE O_CARTLIST
            SET CLIST_SELECT = PSELECT
            WHERE CART_ID = VCART_ID
            AND PDT_ID = PPDT_ID;

            DBMS_OUTPUT.PUT_LINE('���� ���ΰ� ����Ǿ����ϴ�.');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
             
        ELSE
            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� ���õ� ��ǰ�� �������� �ʽ��ϴ�.');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
        END IF;

        -- ��ٱ��� (��ǰ��ȸ)�� ������ ������Ʈ�ϴ� ���ν��� ȣ��
        UP_CART_CHECK(PUSER_ID);
        UP_CARTLIST_PRICE(PUSER_ID);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('���� ���θ� ������Ʈ�ϴ� �� ������ �߻��߽��ϴ�. ���� �޽���: ' || SQLERRM);
    END;
END;








-- 6) ��ٱ��� (��ǰ ����) 
CREATE OR REPLACE PROCEDURE UP_CART_DELETE (
    PUSER_ID IN NUMBER,
    PPDT_ID IN NUMBER,
    POPT_ID IN NUMBER  -- �ɼ� ID �߰�
) AS
    VCART_ID NUMBER;
    VEXISTING_COUNT NUMBER;
BEGIN
    BEGIN
        -- ��ٱ��� ID ��������
        SELECT CART_ID
        INTO VCART_ID
        FROM O_CART
        WHERE USER_ID = PUSER_ID;

        -- ��ٱ��Ͽ� �ش� ��ǰ�� �ɼ��� �ִ��� Ȯ��
        SELECT COUNT(*)
        INTO VEXISTING_COUNT
        FROM O_CARTLIST
        WHERE CART_ID = VCART_ID
        AND PDT_ID = PPDT_ID
        AND NVL(OPT_ID, 0) = NVL(POPT_ID, 0);  -- �ɼ� ID ��, NULL ó��

        IF VEXISTING_COUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� �ش� ��ǰ�� �������� �ʽ��ϴ�.');
        ELSE
            -- ��ٱ��Ͽ��� ��ǰ ����
            DELETE FROM O_CARTLIST
            WHERE CART_ID = VCART_ID
            AND PDT_ID = PPDT_ID
            AND NVL(OPT_ID, 0) = NVL(POPT_ID, 0);  -- �ɼ� ID ��, NULL ó��

            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ��� ��ǰ�� ���ŵǾ����ϴ�.');
        END IF;
        
        -- ��ٱ��� ���� ���
        UP_CART_CHECK(PUSER_ID);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('��ٱ��Ͽ� ��ǰ�� �������� �ʽ��ϴ�.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('��ǰ�� ��ٱ��Ͽ��� �����ϴ� �� ������ �߻��߽��ϴ�. ���� �޽���: ' || SQLERRM);
    END;
END;











 
 	
--7) ���๮

-- ��ǰâ���� ��ٱ��Ϸ� ��ǰ �߰�
EXECUTE get_productinfo(1);
EXECUTE UP_CARTLIST_ADD(1001, 1, NULL, 1);
--                      ȸ�� ��ǰ �ɼ� ����


-- ��ǰâ���� ���� ��ǰ �߰� (���� ����)
EXECUTE get_productinfo(1);
EXECUTE UP_CARTLIST_ADD(1001,1,NULL,1);
--                      ȸ�� ��ǰ �ɼ� ����


-- ��ǰâ���� ���� ��ǰ �߰� (����� ���� �߰�)
EXECUTE get_productinfo(1);
EXECUTE UP_CARTLIST_ADD(1001,1,NULL,100);


-- ��ǰâ���� �ɼ� ���� ���ϰ� �߰��Ϸ��� �ϴ� ���
EXECUTE get_productinfo(168);
EXECUTE UP_CARTLIST_ADD(1001,168,NULL,1);
--                      ȸ�� ��ǰ �ɼ� ����


-- ��ǰâ���� �ش� ��ǰ���� �������� �ʴ� �ɼ� �߰��Ϸ��� �ϴ� ���
EXECUTE get_productinfo(168);
EXECUTE UP_CARTLIST_ADD(1001,168,4,1);
--                      ȸ�� ��ǰ �ɼ� ����





-- ��ǰâ���� �ɼ� �����ϰ� �߰�
EXECUTE get_productinfo(168);
EXECUTE UP_CARTLIST_ADD(1001,168,7,1);
--                      ȸ�� ��ǰ �ɼ� ����


-- ��ٱ��Ϸ� �̵��ؼ� ��ٱ��� ��ȸ
EXECUTE UP_CART_CHECK(1001);
--                    ȸ��

-- ��ٱ��Ͽ��� ��ǰ ���� ���� (������ 1 �̸����� ���ҽ�Ű���� ���)
EXECUTE UP_CARTLIST_UPDATE (1001, 1, -3);
--                          ȸ�� ��ǰ ����


-- ��ٱ��Ͽ��� ��ǰ ���� ���� (������ ���ҽ�ų ���)
EXECUTE UP_CARTLIST_UPDATE (1001, 1, -1);
--                          ȸ�� ��ǰ ������


-- ��ٱ��Ͽ��� ��ǰ ����, �̼���
EXECUTE UP_CARTLIST_SELECT (1001, 1,'N');
--                          ȸ�� ��ǰ ���ÿ���

EXECUTE UP_CARTLIST_SELECT (1001, 1,'Y');
--                          ȸ�� ��ǰ ���ÿ���



-- N ���� ��ġ ���� (��ǰ ����)
EXECUTE UP_CART_DELETE(1001, 1, NULL);
--                     ȸ�� ��ǰ �ɼ�

-- ��� ���۷����� 2��, �ɼ�: �÷η��� (��ǰ ����)
EXECUTE UP_CART_DELETE(1001, 168, 7);
--                     ȸ�� ��ǰ �ɼ�


