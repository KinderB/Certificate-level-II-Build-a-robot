*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Desktop
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Email.Exchange
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault

*** Keywords ***
Open the robot order website
    ${Url}=    Get Secret    Url
    Open Available Browser    url=${Url}[url]    maximized=True

Get orders
    [Documentation]    Dawnload the csv file and return the table
    Add heading    Send Link
    Add text input    Link    label=Link order file
    ${dialog}=    Run dialog
    Download    url=${dialog.Link}    overwrite=True    target_file=${TEMPDIR}${/}orders.csv
    ${orders}=    Read table from CSV    ${TEMPDIR}${/}orders.csv
    [Return]    ${orders}

Close the annoying modal
    Click Button    OK

Fill the form
    [Documentation]    recive the information about each order and fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    Preview

Click on button order until Succeeds
    Click Button    Order
    Wait Until Page Contains Element    //h3

Submit the order
    Wait Until Keyword Succeeds    5x    3 sec    Click on button order until Succeeds

Store the receipt as a PDF file
    [Arguments]    ${Order_number}
    ${Receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${Receipt}    ${OUTPUT_DIR}${/}receipts${/}${Order_number}.pdf
    [Return]    ${OUTPUT_DIR}${/}receipts${/}${Order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${Order_number}
    Screenshot    id:robot-preview-image    ${TEMPDIR}${/}${Order_number}.png
    [Return]    ${TEMPDIR}${/}${Order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${Lscreenshot}=    Create List    ${pdf}    ${screenshot}
    #    Open Pdf    ${pdf}
    Add Files To Pdf    ${Lscreenshot}    ${pdf}
    # Close Pdf

Go to order another robot
    Click Button    Order another robot

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts${/}    ${OUTPUT_DIR}${/}receipts.zip

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Log    ${row}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
