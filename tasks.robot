*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.RobotLogListener


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Open the intranet website
    Download CSV file
    Fill order forms and recollect recipts
    Create ZIP with PDF files

***Variables***
    

*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill order forms and recollect recipts
    ${dataTable}=    Read table from CSV    orders.csv    header=True
    FOR    ${data}    IN    @{dataTable}
        Fill and submit one form    ${data}
    END

Fill and submit one form
    Click Button    OK
    [Arguments]    ${dataTable}
    Select From List By Value    head    ${dataTable}[Head]
    Click Element    xpath://input[@type='radio' and @value=${dataTable}[Body]]
    Input Text    css=.form-control    ${dataTable}[Legs]
    Input Text    address    ${dataTable}[Address]
    Click Button    preview
    Wait Until Keyword Succeeds    10x    1s    Submit the order And Keep Checking Until Success
    Take a screenshot of the robot    ${dataTable}
    Store the receipt in a PDF file    ${dataTable}
    Store the robot preview in the recipt PDF    ${dataTable}
    Click Button    order-another

Submit the order And Keep Checking Until Success
    Click Element    order
    Element Should Be Visible    xpath://div[@id="receipt"]/p[1]
    Element Should Be Visible    id:order-completion


Take a screenshot of the robot
    [Arguments]    ${dataTable}
    Wait Until Element Is Visible    css=img[alt="Head"]
    Wait Until Element Is Visible    css=img[alt="Body"]
    Wait Until Element Is Visible    css=img[alt="Legs"]
    ${screenshot}    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot_previews${/}${dataTable}[Order number].png

Store the receipt in a PDF file
    [Arguments]    ${dataTable}
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${dataTable}[Order number].pdf

Store the robot preview in the recipt PDF
    [Arguments]    ${dataTable}
    Open Pdf    ${OUTPUT_DIR}${/}${dataTable}[Order number].pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}robot_previews${/}${dataTable}[Order number].png    ${OUTPUT_DIR}${/}${dataTable}[Order number].pdf
    Close Pdf

Create ZIP with PDF files
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}recipts.zip