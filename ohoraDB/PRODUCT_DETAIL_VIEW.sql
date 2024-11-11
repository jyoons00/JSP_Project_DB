
------------------------------------����ȭ�� �� ���� �Ż�ǰ
CREATE OR REPLACE VIEW thismonth_new
AS
    SELECT PDT_REVIEW_COUNT �����
        , PDT_NAME ��ǰ��
        , PDT_DISCOUNT_RATE ���η�
        , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
        , PDT_AMOUNT ��ǰ����
    FROM o_product
    WHERE EXTRACT(MONTH FROM PDT_ADDDATE) = EXTRACT(MONTH FROM SYSDATE);

SELECT * FROM thismonth_new;

------------------------------------����ȭ�� �ְ� ����Ʈ
-- BEST���� �� �տ� 10���� ����ϰ� ����
-- BEST ��ȸ�ϴ� ���ν������� ��� ������ 12���� 10���� ����.









--------------------------�������� ���
CREATE OR REPLACE PROCEDURE product_detail_page
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
    DBMS_OUTPUT.PUT_LINE('������: ' || vPDT_DISCOUNT_RATE || '%');
    DBMS_OUTPUT.PUT_LINE('���ΰ�: ' || vDiscounted_Amount);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('��ǰ��ȣ ' || pPDT_ID || '�� �ش��ϴ� ��ǰ�� ã�� �� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('����ġ ���� ������ �߻��߽��ϴ�: ' || SQLERRM);
END;



EXECUTE product_detail_page(3);

SELECT * FROM o_product;


-----------------------��ǰ �������� ���� �� �ڵ����� ��ȸ������ �߰��Ǵ�...
CREATE OR REPLACE PROCEDURE product_detail_page
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
    -- ��ȸ�� 1 ����
    UPDATE O_PRODUCT
    SET PDT_VIEWCOUNT = NVL(PDT_VIEWCOUNT, 0) + 1
    WHERE PDT_ID = pPDT_ID;
    -- ��� ���
    DBMS_OUTPUT.PUT_LINE(vPDT_NAME);
    DBMS_OUTPUT.PUT_LINE(vPDT_AMOUNT || ' ' || vDiscounted_Amount || ' ' || vPDT_DISCOUNT_RATE || '%');
    DBMS_OUTPUT.PUT_LINE('');
    detail_page_extraproduct(pPDT_ID);
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('��ǰ��ȣ ' || pPDT_ID || '�� �ش��ϴ� ��ǰ�� ã�� �� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('����ġ ���� ������ �߻��߽��ϴ�: ' || SQLERRM);
END;

EXECUTE product_detail_page(3);
SELECT * FROM o_product;



SELECT * FROM o_category;
--------------------------------------�߰�������ǰ ��� PROCEDURE
CREATE OR REPLACE PROCEDURE detail_page_extraproduct
(
    pPDT_ID IN O_PRODUCT.PDT_ID%TYPE
)
IS
    vCAT_ID O_CATEGORY.CAT_ID%TYPE;
    vSCAT_ID O_SUBCATEGORY.SCAT_ID%TYPE;
    vUSER_EXISTS NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('�߰�������ǰ');
    
    -- ��ǰ�� ī�װ��� ����ī�װ� ID ��������
    SELECT CAT_ID, SCAT_ID
    INTO vCAT_ID, vSCAT_ID
    FROM O_PRODUCT
    WHERE PDT_ID = pPDT_ID;
    
    -- O_ORDER ���̺� �����ϴ� USER_ID�� üũ
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM O_ORDER o
        WHERE EXISTS (SELECT 1 FROM O_USER u WHERE u.USER_ID = o.USER_ID)
    ) THEN 1 ELSE 0 END
    INTO vUSER_EXISTS
    FROM DUAL;
    
    -- ���ǹ��� ����Ͽ� �ٸ� ���ν��� ȣ��
    IF vCAT_ID = 1 AND vSCAT_ID = 1 THEN 
        get_productinfo(169);
        get_productinfo(170);
        get_productinfo(172);
    ELSIF vCAT_ID = 1 AND vSCAT_ID = 2 THEN
        IF vUSER_EXISTS = 1 THEN
            get_productinfo(165);
            get_productinfo(169);
            get_productinfo(170);
            get_productinfo(174);
        ELSE
            get_productinfo(169);
            get_productinfo(170);
            get_productinfo(174);
        END IF;
    ELSIF vCAT_ID = 2 AND vSCAT_ID = 1 THEN
        get_productinfo(169);
        get_productinfo(170);
    ELSIF vCAT_ID = 1 AND pPDT_ID NOT IN (179, 180, 181, 182) THEN
        get_productinfo(169);
        get_productinfo(170);
    ELSE 
        DBMS_OUTPUT.PUT_LINE('�߰�������ǰ ����');
    END IF;
END;


EXECUTE detail_page_extraproduct(107);

------------------------------------�߰�������ǰ ���� �������� PROCEDURE
CREATE OR REPLACE PROCEDURE get_productinfo
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

EXECUTE get_productinfo(170);



----------------------------------------------------��ǰ ��� ���
--���� ��� - �Ż�ǰ, �α��ǰ, ��ȸ��
--�Ż�ǰ
SELECT PDT_ADDDATE ��ǰ�߰���
    , PDT_REVIEW_COUNT �����
    , PDT_NAME ��ǰ��
    , PDT_DISCOUNT_RATE ���η�
    , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
    , PDT_AMOUNT ��ǰ����
FROM O_PRODUCT
ORDER BY PDT_ADDDATE DESC;

SELECT *
FROM(
SELECT PDT_ADDDATE ��ǰ�߰���
    , PDT_REVIEW_COUNT �����
    , PDT_NAME ��ǰ��
    , PDT_DISCOUNT_RATE ���η�
    , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
    , PDT_AMOUNT ��ǰ����
    ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM O_PRODUCT
ORDER BY PDT_ADDDATE DESC
)
WHERE rn BETWEEN 1 AND 12;

----------------------------------�Ż�ǰ ������ ���ν�����    (�Ż�ǰ ������ ����Ʈ)
------1 ������ 1������, 2 ������ 2������
CREATE OR REPLACE PROCEDURE pr_pdtpage_recentday(
    p_page_number IN NUMBER  -- ������ ��ȣ (��: 1, 2, 3, ...)
)
IS
    v_page_size CONSTANT NUMBER := 12;  -- ������ ũ�⸦ 12�� ����

    CURSOR c_pdt_page IS
    WITH RankedProducts AS (
        SELECT PDT_ADDDATE AS ��ǰ�߰���
            , PDT_REVIEW_COUNT AS �����
            , PDT_NAME AS ��ǰ��
            , PDT_DISCOUNT_RATE AS ���η�
            , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
            , PDT_AMOUNT AS ��ǰ����
            , ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
        FROM O_PRODUCT
        ORDER BY PDT_ADDDATE DESC
    )
    SELECT *
    FROM RankedProducts
    WHERE rn BETWEEN ((p_page_number - 1) * v_page_size + 1) AND (p_page_number * v_page_size);

    -- ���ڵ� Ÿ���� �����Ͽ� Ŀ������ ��ȯ�Ǵ� �����Ϳ� ��ġ��ŵ�ϴ�.
    v_record c_pdt_page%ROWTYPE;
BEGIN
    OPEN c_pdt_page;

    LOOP
        FETCH c_pdt_page INTO v_record;
        EXIT WHEN c_pdt_page%NOTFOUND;

        -- ������ ���
        DBMS_OUTPUT.PUT_LINE(v_record.����� || '  ' ||
                             v_record.��ǰ�� || '  ' ||
                             v_record.���ΰ��� || '  ' ||
                             v_record.��ǰ���� || '  ' ||
                             v_record.���η�
                             );
    END LOOP;

    CLOSE c_pdt_page;
END;

EXECUTE pr_pdtpage_recentday(1);






--�α��ǰ
SELECT PDT_SALES_COUNT �Ǹż�
    , PDT_REVIEW_COUNT �����
    , PDT_NAME ��ǰ��
    , PDT_DISCOUNT_RATE ���η�
    , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
    , PDT_AMOUNT ��ǰ����
FROM O_PRODUCT
ORDER BY PDT_SALES_COUNT DESC;

SELECT *
FROM (
    SELECT PDT_SALES_COUNT �Ǹż�
    , PDT_REVIEW_COUNT �����
    , PDT_NAME ��ǰ��
    , PDT_DISCOUNT_RATE ���η�
    , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
    , PDT_AMOUNT ��ǰ����
    ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM O_PRODUCT
ORDER BY PDT_SALES_COUNT DESC
)
WHERE rn BETWEEN 1 AND 12;

----------------------------------�α��ǰ ������ ���ν�����
------1 ������ 1������, 2 ������ 2������
CREATE OR REPLACE PROCEDURE pr_pdtpage_popular
(
     p_page_number IN NUMBER  -- ������ ��ȣ (��: 1, 2, 3, ...)
)
IS
     v_page_size CONSTANT NUMBER := 12;  -- ������ ũ�⸦ 12�� ����

     CURSOR c_pdt_page IS
    WITH RankedProducts AS (
        SELECT 
            PDT_ADDDATE AS ��ǰ�߰���,
            PDT_REVIEW_COUNT AS �����,
            PDT_NAME AS ��ǰ��,
            PDT_DISCOUNT_RATE AS ���η�,
            ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
            PDT_AMOUNT AS ��ǰ����,
            ROW_NUMBER() OVER (ORDER BY PDT_SALES_COUNT DESC) AS rn
        FROM O_PRODUCT
        ORDER BY PDT_SALES_COUNT DESC
    )
    SELECT *
    FROM RankedProducts
    WHERE rn BETWEEN ((p_page_number - 1) * v_page_size + 1) AND (p_page_number * v_page_size);

    -- ���ڵ� Ÿ���� �����Ͽ� Ŀ������ ��ȯ�Ǵ� �����Ϳ� ��ġ
    v_record c_pdt_page%ROWTYPE;
BEGIN
    OPEN c_pdt_page;

    LOOP
        FETCH c_pdt_page INTO v_record;
        EXIT WHEN c_pdt_page%NOTFOUND;

        -- ������ ���
        DBMS_OUTPUT.PUT_LINE(v_record.����� || '  ' ||
                             v_record.��ǰ�� || '  ' ||
                             v_record.���ΰ��� || '  ' ||
                             v_record.��ǰ���� || '  ' ||
                             v_record.���η�
                             );
    END LOOP;

    CLOSE c_pdt_page;
END;

EXECUTE pr_pdtpage_popular(1);



--��ȸ��
SELECT PDT_VIEWCOUNT
    , PDT_REVIEW_COUNT �����
    , PDT_NAME ��ǰ��
    , PDT_DISCOUNT_RATE ���η�
    , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE/100), 2) ���ΰ���
    , PDT_AMOUNT ��ǰ����
FROM O_PRODUCT
ORDER BY PDT_VIEWCOUNT;

SELECT *
FROM (
    SELECT 
        PDT_VIEWCOUNT,
        PDT_REVIEW_COUNT AS �����,
        PDT_NAME AS ��ǰ��,
        PDT_DISCOUNT_RATE AS ���η�,
        ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
        PDT_AMOUNT AS ��ǰ����,
        ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
    FROM O_PRODUCT
)
WHERE rn BETWEEN 1 AND 12;

----------------------------------��ȸ�� ������ ���ν�����
------1 ������ 1������, 2 ������ 2������
CREATE OR REPLACE PROCEDURE pr_pdtpage_viewcount
(
     p_page_number IN NUMBER  -- ������ ��ȣ (��: 1, 2, 3, ...)
)
IS
     v_page_size CONSTANT NUMBER := 12;  -- ������ ũ�⸦ 12�� ����

     CURSOR c_pdt_page IS
    WITH RankedProducts AS (
        SELECT 
            PDT_ADDDATE AS ��ǰ�߰���,
            PDT_REVIEW_COUNT AS �����,
            PDT_NAME AS ��ǰ��,
            PDT_DISCOUNT_RATE AS ���η�,
            ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
            PDT_AMOUNT AS ��ǰ����,
            ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
        FROM O_PRODUCT
        ORDER BY PDT_VIEWCOUNT DESC
    )
    SELECT *
    FROM RankedProducts
    WHERE rn BETWEEN ((p_page_number - 1) * v_page_size + 1) AND (p_page_number * v_page_size);

    -- ���ڵ� Ÿ���� �����Ͽ� Ŀ������ ��ȯ�Ǵ� �����Ϳ� ��ġ
    v_record c_pdt_page%ROWTYPE;
BEGIN
    OPEN c_pdt_page;

    LOOP
        FETCH c_pdt_page INTO v_record;
        EXIT WHEN c_pdt_page%NOTFOUND;

        -- ������ ���
        DBMS_OUTPUT.PUT_LINE(v_record.����� || '  ' ||
                             v_record.��ǰ�� || '  ' ||
                             v_record.���ΰ��� || '  ' ||
                             v_record.��ǰ���� || '  ' ||
                             v_record.���η�
                             );
    END LOOP;

    CLOSE c_pdt_page;
END;

EXECUTE pr_pdtpage_viewcount(15);
EXECUTE pr_pdtpage_viewcount(16);


-----------------------------------PRODUCT���� �����κ�,�÷���, ���ξ����� ���

--������ ���ϸ� design_id = 1

SELECT p.PDT_REVIEW_COUNT AS �����
        , p.PDT_NAME AS ��ǰ��
        , p.PDT_DISCOUNT_RATE AS ���η�
        , ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , p.PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM O_PDTDESIGN d JOIN O_PRODUCT p ON d.PDT_ID = p.PDT_ID
WHERE d.DESIGN_ID = 1;

---------------------------------------------�����κ� ���ν���
CREATE OR REPLACE PROCEDURE searchby_design
(
    pDESIGN_ID IN O_PDTDESIGN.DESIGN_ID%TYPE  -- �Է� �Ķ����
)
IS
    -- Ŀ�� ����
    CURSOR c_design IS
        SELECT 
            p.PDT_REVIEW_COUNT AS �����,
            p.PDT_NAME AS ��ǰ��,
            p.PDT_DISCOUNT_RATE AS ���η�,
            ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
            p.PDT_AMOUNT AS ��ǰ����,
            ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
        FROM O_PDTDESIGN d 
        JOIN O_PRODUCT p ON d.PDT_ID = p.PDT_ID
        WHERE d.DESIGN_ID = pDESIGN_ID;
    -- Ŀ������ ��ȯ�� �� Ÿ�� ����
    v_record c_design%ROWTYPE;
    
BEGIN
    -- Ŀ�� ����
    OPEN c_design;
    -- Ŀ������ �����͸� �� �྿ ������ ó��
    LOOP
        FETCH c_design INTO v_record;
        EXIT WHEN c_design%NOTFOUND;
        -- ������ ���
        DBMS_OUTPUT.PUT_LINE('��ǰ��: ' || v_record.��ǰ�� ||
                             ', �����: ' || v_record.����� ||
                             ', ���η�: ' || v_record.���η� || '%' ||
                             ', ��ǰ����: ' || v_record.��ǰ���� || '��' ||
                             ', ���ΰ���: ' || v_record.���ΰ��� || '��');
    END LOOP;
    -- Ŀ�� �ݱ�
    CLOSE c_design;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�ش� DESIGN_ID�� ���� �����Ͱ� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
END;

EXECUTE searchby_design(1);




-- �÷� �ڶ���ũ COLOR_ID = 1
SELECT *
FROM(
SELECT p.PDT_REVIEW_COUNT AS �����
        , p.PDT_NAME AS ��ǰ��
        , p.PDT_DISCOUNT_RATE AS ���η�
        , ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , p.PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM O_PDTCOLOR c JOIN O_PRODUCT p ON c.PDT_ID = p.PDT_ID
WHERE COLOR_ID = 1
)
WHERE rn BETWEEN 1 AND 12;
-----------------------------------------------���� ���ν���
CREATE OR REPLACE PROCEDURE searchby_color
(
    pCOLOR_ID IN O_PDTCOLOR.COLOR_ID%TYPE  -- �Է� �Ķ����
)
IS
    -- Ŀ�� ����
    CURSOR c_color IS
        SELECT 
            p.PDT_REVIEW_COUNT AS �����,
            p.PDT_NAME AS ��ǰ��,
            p.PDT_DISCOUNT_RATE AS ���η�,
            ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
            p.PDT_AMOUNT AS ��ǰ����,
            ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
        FROM O_PDTCOLOR d 
        JOIN O_PRODUCT p ON d.PDT_ID = p.PDT_ID
        WHERE d.COLOR_ID = pCOLOR_ID;
    
    -- Ŀ������ ��ȯ�� �� Ÿ�� ����
    v_record c_color%ROWTYPE;
BEGIN
    -- Ŀ�� ����
    OPEN c_color;
    
    -- Ŀ������ �����͸� �� �྿ ������ ó��
    LOOP
        FETCH c_color INTO v_record;
        EXIT WHEN c_color%NOTFOUND;
        
        -- ������ ���
        DBMS_OUTPUT.PUT_LINE('��ǰ��: ' || v_record.��ǰ�� ||
                             ', �����: ' || v_record.����� ||
                             ', ���η�: ' || v_record.���η� || '%' ||
                             ', ��ǰ����: ' || v_record.��ǰ���� || '��' ||
                             ', ���ΰ���: ' || v_record.���ΰ��� || '��' ||
                             ', ����: ' || v_record.rn);
    END LOOP;

    -- Ŀ�� �ݱ�
    CLOSE c_color;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�ش� COLOR_ID�� ���� �����Ͱ� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
END;

EXECUTE searchby_color(11);


-- ���ξ� Ǯ�÷� LINEUP_ID = 2
SELECT *
FROM(
SELECT p.PDT_REVIEW_COUNT AS �����
        , p.PDT_NAME AS ��ǰ��
        , p.PDT_DISCOUNT_RATE AS ���η�
        , ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , p.PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM O_PDTLINEUP l JOIN O_PRODUCT p ON l.PDT_ID = p.PDT_ID
WHERE LINEUP_ID = 2
)
WHERE rn BETWEEN 1 AND 12;
-------------------------------------------���ξ��� ���ν���
CREATE OR REPLACE PROCEDURE searchby_lineup
(
    pLINEUP_ID O_PDTLINEUP.LINEUP_ID%TYPE
)
IS
    CURSOR c_lineup IS
    SELECT p.PDT_REVIEW_COUNT AS �����
        , p.PDT_NAME AS ��ǰ��
        , p.PDT_DISCOUNT_RATE AS ���η�
        , ROUND(p.PDT_AMOUNT * (1 - p.PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , p.PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
    FROM O_PDTLINEUP l JOIN O_PRODUCT p ON l.PDT_ID = p.PDT_ID
    WHERE l.LINEUP_ID = pLINEUP_ID;
    
    v_record c_lineup%ROWTYPE;
BEGIN
    OPEN c_lineup;
        LOOP
        FETCH c_lineup INTO v_record;
        EXIT WHEN c_lineup%NOTFOUND;
    
        DBMS_OUTPUT.PUT_LINE('��ǰ��: ' || v_record.��ǰ�� ||
                             ', �����: ' || v_record.����� ||
                             ', ���η�: ' || v_record.���η� || '%' ||
                             ', ��ǰ����: ' || v_record.��ǰ���� || '��' ||
                             ', ���ΰ���: ' || v_record.���ΰ��� || '��');
        
        END LOOP;
    
    CLOSE c_lineup;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('�ش� LINEUP_ID�� ���� �����Ͱ� �����ϴ�.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('���� �߻�: ' || SQLERRM);
END;

EXECUTE searchby_lineup(3);


-----------------------------------------------------�ƿ﷿ ��ȸ
--����, ��� �� ���η� 30% �̻��� ��ǰ��
SELECT *
FROM(
SELECT PDT_REVIEW_COUNT AS �����
        , PDT_NAME AS ��ǰ��
        , PDT_DISCOUNT_RATE AS ���η�
        , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
FROM o_product
WHERE cat_id IN (1,2) AND PDT_DISCOUNT_RATE >= 30
)
--WHERE rn BETWEEN 25 AND 36;
--WHERE rn BETWEEN 13 AND 24;
WHERE rn BETWEEN 1 AND 12;


---------------------------------------�ƿ﷿ ��ȸ ���ν���
CREATE OR REPLACE PROCEDURE pr_disp_outlet
(
     p_page_number IN NUMBER  -- ������ ��ȣ (��: 1, 2, 3, ...)
)
IS
     v_page_size CONSTANT NUMBER := 12;  -- ������ ũ�⸦ 12�� ����

     CURSOR c_pdt_page IS
    WITH RankedProducts AS (
        SELECT PDT_REVIEW_COUNT AS �����
        , PDT_NAME AS ��ǰ��
        , PDT_DISCOUNT_RATE AS ���η�
        , ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���
        , PDT_AMOUNT AS ��ǰ����
        ,  ROW_NUMBER() OVER (ORDER BY PDT_VIEWCOUNT DESC) AS rn
        FROM o_product
        WHERE cat_id IN (1,2) AND PDT_DISCOUNT_RATE >= 30
    )
    SELECT *
    FROM RankedProducts
    WHERE rn BETWEEN ((p_page_number - 1) * v_page_size + 1) AND (p_page_number * v_page_size);

    -- ���ڵ� Ÿ���� �����Ͽ� Ŀ������ ��ȯ�Ǵ� �����Ϳ� ��ġ
    v_record c_pdt_page%ROWTYPE;
BEGIN
    OPEN c_pdt_page;

    LOOP
        FETCH c_pdt_page INTO v_record;
        EXIT WHEN c_pdt_page%NOTFOUND;

        -- ������ ���
        DBMS_OUTPUT.PUT_LINE(v_record.����� || '  ' ||
                             v_record.��ǰ�� || '  ' ||
                             v_record.���ΰ��� || '  ' ||
                             v_record.��ǰ���� || '  ' ||
                             v_record.���η� || '%');
    END LOOP;

    CLOSE c_pdt_page;
END;

EXECUTE pr_disp_outlet(1);

----------------------------BEST ��ȸ
WITH RankedProducts AS (
    SELECT 
        PDT_SALES_COUNT AS �Ǹż�,
        PDT_REVIEW_COUNT AS �����,
        PDT_NAME AS ��ǰ��,
        PDT_DISCOUNT_RATE AS ���η�,
        ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
        PDT_AMOUNT AS ��ǰ����,
        ROW_NUMBER() OVER (ORDER BY PDT_SALES_COUNT DESC) AS rn,
        COUNT(*) OVER () AS total_count  -- ��ü ��ǰ ���� ���
    FROM O_PRODUCT
)
SELECT *
FROM (
        SELECT �Ǹż�, �����, ��ǰ��, ���η�, ���ΰ���, ��ǰ����,
            rn,
            total_count,
            PERCENT_RANK() OVER (ORDER BY �Ǹż� DESC) AS rank_pct
        FROM RankedProducts
)
WHERE rank_pct <= 0.30  -- ���� 30% ����
AND rn BETWEEN 1 AND 12; -- ������ ����

-----------------------------------------BEST ��ȸ ���ν���
CREATE OR REPLACE PROCEDURE pr_disp_best
(
    p_page_number IN NUMBER  -- ������ ��ȣ (��: 1, 2, 3, ...)
)
IS
    v_page_size CONSTANT NUMBER := 12;  -- ������ ũ�⸦ 12�� ����

    CURSOR c_pdt_page IS
    WITH RankedProducts AS (
        SELECT 
            PDT_SALES_COUNT AS �Ǹż�,
            PDT_REVIEW_COUNT AS �����,
            PDT_NAME AS ��ǰ��,
            PDT_DISCOUNT_RATE AS ���η�,
            ROUND(PDT_AMOUNT * (1 - PDT_DISCOUNT_RATE / 100), 2) AS ���ΰ���,
            PDT_AMOUNT AS ��ǰ����,
            ROW_NUMBER() OVER (ORDER BY PDT_SALES_COUNT DESC) AS rn,
            PERCENT_RANK() OVER (ORDER BY PDT_SALES_COUNT DESC) AS rank_pct
        FROM O_PRODUCT
    )
    SELECT *
    FROM RankedProducts
    WHERE rank_pct <= 0.30  -- ���� 30% ����
    AND rn BETWEEN ((p_page_number - 1) * v_page_size + 1) AND (p_page_number * v_page_size);  -- ������ ����

    -- ���ڵ� Ÿ���� �����Ͽ� Ŀ������ ��ȯ�Ǵ� �����Ϳ� ��ġ
    v_record c_pdt_page%ROWTYPE;
BEGIN
    OPEN c_pdt_page;

    LOOP
        FETCH c_pdt_page INTO v_record;
        EXIT WHEN c_pdt_page%NOTFOUND;

        -- ������ ���
        DBMS_OUTPUT.PUT_LINE(v_record.����� || '  ' ||
                             v_record.��ǰ�� || '  ' ||
                             v_record.���ΰ��� || '  ' ||
                             v_record.��ǰ���� || '  ' ||
                             v_record.���η�);
    END LOOP;

    CLOSE c_pdt_page;
END;

EXECUTE pr_disp_best(2);






----------------------------------------NOTICE ��� ��
CREATE OR REPLACE VIEW notice_view
AS
    SELECT notice_title ����
    FROM o_notice;

SELECT * FROM notice_view;


--------------------------------------NOTICE ���� ��
CREATE OR REPLACE VIEW notice_detail_view
AS
    SELECT notice_title ����
        , NOTICE_WRITER �ۼ���
        , NOTICE_WRITEDATE �ۼ���
        , NOTICE_VIEWCOUNT ��ȸ��
        , NOTICE_CONTENT ����
    FROM O_NOTICE
    WHERE NOTICE_ID = 1;
    
SELECT * FROM notice_detail_view;


CREATE OR REPLACE PROCEDURE pr_notice_detail
(
     pNOTICE_ID IN O_NOTICE.NOTICE_ID%TYPE
)
IS
    vnotice_title     O_NOTICE.notice_title%TYPE;
    vNOTICE_WRITER    O_NOTICE.NOTICE_WRITER%TYPE;
    vNOTICE_WRITEDATE O_NOTICE.NOTICE_WRITEDATE%TYPE;
    vNOTICE_VIEWCOUNT O_NOTICE.NOTICE_VIEWCOUNT%TYPE;
    vNOTICE_CONTENT   O_NOTICE.NOTICE_CONTENT%TYPE;
    
BEGIN
    SELECT notice_title, NOTICE_WRITER, NOTICE_WRITEDATE, NOTICE_VIEWCOUNT, NOTICE_CONTENT
        INTO vnotice_title, vNOTICE_WRITER, vNOTICE_WRITEDATE, vNOTICE_VIEWCOUNT, vNOTICE_CONTENT
    FROM O_NOTICE
    WHERE NOTICE_ID = pNOTICE_ID;
    
    UPDATE O_NOTICE
    SET NOTICE_VIEWCOUNT = NVL(NOTICE_VIEWCOUNT, 0) + 1
    WHERE NOTICE_ID = pNOTICE_ID;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('����: ' || vnotice_title);
    DBMS_OUTPUT.PUT_LINE('�ۼ���: ' || vNOTICE_WRITER);
    DBMS_OUTPUT.PUT_LINE('�ۼ���: ' || vNOTICE_WRITEDATE || ' ' || '��ȸ��' || vNOTICE_VIEWCOUNT);
    DBMS_OUTPUT.PUT_LINE(vNOTICE_CONTENT);
END;

EXECUTE pr_notice_detail(1);

SELECT * FROM o_notice;

------------------------------------------------------O_ASK ��� ��
--������ ���� �ۼ��� ���Ǹ� ������ ��
CREATE OR REPLACE VIEW ask_view
AS
    SELECT ASK_ID ��ȣ
        , ASK_TITLE ����
        , ASK_WRITER �ۼ���
        , ASK_WRITEDATE �ۼ���
        , ASK_ISANSWER �亯
    FROM o_ask;
    
SELECT * FROM ask_view;

SELECT * FROM o_ask;


------------------------------------O_ASK ��� ���ν���
CREATE OR REPLACE PROCEDURE myask_list
(
    pUSER_ID IN O_ASK.USER_ID%TYPE
)
IS
    CURSOR c_ask IS
        SELECT ASK_ID, ASK_TITLE, ASK_WRITER, ASK_WRITEDATE, ASK_ISANSWER 
        FROM O_ASK
        WHERE USER_ID = pUSER_ID;

    vASK_ID         O_ASK.ASK_ID%TYPE;
    vASK_TITLE      O_ASK.ASK_TITLE%TYPE;
    vASK_WRITER     O_ASK.ASK_WRITER%TYPE;
    vASK_WRITEDATE  O_ASK.ASK_WRITEDATE%TYPE;
    vASK_ISANSWER   O_ASK.ASK_ISANSWER%TYPE;
BEGIN
    -- Ŀ�� ����
    OPEN c_ask;
    LOOP
        FETCH c_ask INTO vASK_ID, vASK_TITLE, vASK_WRITER, vASK_WRITEDATE, vASK_ISANSWER;
        EXIT WHEN c_ask%NOTFOUND;

        -- ���
        DBMS_OUTPUT.PUT_LINE('��ȣ: ' || vASK_ID || 
                             ', ����: ' || vASK_TITLE ||
                             ', �ۼ���: ' || vASK_WRITER ||
                             ', �ۼ���: ' || vASK_WRITEDATE ||
                             ', �亯: ' || vASK_ISANSWER);
    END LOOP;
    CLOSE c_ask;
END;

EXECUTE myask_list(1002);



