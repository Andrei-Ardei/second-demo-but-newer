*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library            RPA.Browser.Selenium
Library            RPA.HTTP
Library            RPA.Tables
Library            RPA.PDF
Library    OperatingSystem
Library    RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot orders website
    Fill the form
    Archive orders into a zip file
    

*** Keywords ***
Open the robot orders website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read orders file
    RETURN    ${orders}
Read orders file
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Fill the form
    ${orders}=    Download the orders file
    FOR    ${row}    IN    @{orders}
        Fill one form    ${row}     
    END

Fill one form
    [Arguments]    ${row}
    Click Button    //button[contains(.,'OK')]
    Select From List By Index    head    ${row}[Head]
    Click Button When Visible    id:id-body-${row}[Body]
    Input Text    //div[@id='root']/div/div/div/div/form/div[3]/input    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    preview
    Wait Until Keyword Succeeds    10x    1s    Click order and confirm there is no error
    Collect order details and store them into a PDF    ${row}
    Click Button    id:order-another


Click order and confirm there is no error
    Click Button    order
    Wait Until Element Is Visible    receipt    timeout=1s

Collect order details and store them into a PDF
    [Arguments]    ${order}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    
    ...    ${receipt}    
    ...    ${OUTPUT_DIR}${/}orders${/}${order}[Order number].pdf
    ${screenshot}=    Screenshot    id:robot-preview-image        ${OUTPUT_DIR}${/}orders${/}${order}[Order number].png
    ${list_of_files}=    Create List
    ...    ${screenshot}
    Add Files To Pdf    
    ...    ${list_of_files}    
    ...    ${OUTPUT_DIR}${/}orders${/}${order}[Order number].pdf    
    ...    append=True

Archive orders into a zip file
    Archive Folder With Zip    
    ...    ${OUTPUT_DIR}${/}orders    
    ...    ${OUTPUT_DIR}${/}orders.zip    
    ...    include=*.pdf
    Remove Directory    ${OUTPUT_DIR}${/}orders    True