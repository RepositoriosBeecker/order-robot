*** Settings ***
Documentation       Build and order your robot!

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.FileSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot orders web
    Get Orders
    Fill the form with csv
    Export the order as a PDF


*** Keywords ***
Open the robot orders web
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get Orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Fill the form with csv
    ${order_reps}=    Read table from CSV    orders.csv
    FOR    ${order_rep}    IN    @{order_reps}
        Click Button    OK
        Wait Until Keyword Succeeds    6x    0.5 sec    Fill the form    ${order_rep}
        Wait Until Keyword Succeeds    6x    0.5 sec    Collect Data results    ${order_rep}
    END

Fill the form
    [Arguments]    ${order_bot}
    Select From List By Value    head    ${order_bot}[Head]
    Select Radio Button    body    ${order_bot}[Body]
    Input Text    css:.form-control    ${order_bot}[Legs]
    Input Text    id:address    ${order_bot}[Address]
    Click Button    preview

Collect Data results
    [Arguments]    ${order_bot}
    Screenshot    id:robot-preview    ${OUTPUT_DIR}${/}bot_preview${order_bot}[Order number].png
    Click Button    order
    Screenshot    css:.alert.alert-success    ${OUTPUT_DIR}${/}bot_receipt${order_bot}[Order number].png
    Click Button    order-another

Export the order as a PDF
    Wait Until Element Is Visible    id:order-completion
    ${order_results_html}=    Get Element Attribute    id:receipt    outerHTML
    ${preview_results_html}=    Get Element Attribute    id:robot-preview    outerHTML
    Html To Pdf    ${order_results_html}${preview_results_html}    ${OUTPUT_DIR}${/}orders_results.pdf
