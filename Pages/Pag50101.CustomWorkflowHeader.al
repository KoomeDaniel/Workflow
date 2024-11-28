page 50101 "Custom Workflow List"
{
    ApplicationArea = All;
    Caption = 'Custom Workflow List';
    PageType = List;
    SourceTable = "Custom Workflow Header";
    UsageCategory = Lists;
    CardPageId = "Custom Workflow Header";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the N0. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Approval Status"; Rec."Approval Status")
                {
                    ToolTip = 'Specifies the value of the Approval Status field.', Comment = '%';
                }
            }
        }
    }
}
