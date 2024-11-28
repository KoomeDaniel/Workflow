pageextension 50100 "Purchse & Payables Setup Ext" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast("Number Series")
        {
            field("Workflow Header No."; Rec."Workflow Header No.")
            {
                ApplicationArea = All;
                ToolTip = 'Workflow Header No.';

            }
        }
    }

}
