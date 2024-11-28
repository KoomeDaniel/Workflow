page 50100 "Custom Workflow Header"
{
    ApplicationArea = All;
    Caption = 'Custom Workflow Header';
    PageType = Card;
    SourceTable = "Custom Workflow Header";
    UsageCategory = Administration;
    PromotedActionCategories = 'Approval';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
    actions
    {
        area(Processing)
        {
            action(Reopen)
            {
                ApplicationArea = basic, suite;
                ToolTip = 'Reopen the record for changes';
                Caption = 'Reopen';
                Image = ReOpen;
                Enabled = (Rec."Approval Status" = Rec."Approval Status"::Approved) or (Rec."Approval Status" = Rec."Approval Status"::Rejected);
                promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    if Rec."Approval Status" in [rec."Approval Status"::Approved, Rec."Approval Status"::Rejected] then begin
                        Rec."Approval Status" := Rec."Approval Status"::Open;
                        Rec.Modify(true);
                        Pagecontrols(Rec);
                    end;
                end;
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'Send Approval to change the record';
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Enabled = not HasApprovalEntriesExist;
                    promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef: RecordRef;
                    begin
                        // Message('Send Approval Request');
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkFlowForApproval(RecRef);
                    end;

                }
                action(cancelApprovalRequest)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'Cancel the Approval Request';
                    Caption = 'Cancel Approval Request';
                    Image = CancelApprovalRequest;
                    Enabled = CanCancelApprovalForRecord;
                    promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef: RecordRef;
                    begin
                        // Message('Cancel Approval Request');
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkFlowForApproval(RecRef);
                    end;
                }
            }
        }
        area(Creation)
        {
            group("Approval")
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'Approve the record change';
                    Caption = 'Approve';
                    Image = Approve;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'Reject the record change';
                    Caption = 'Reject';
                    Image = Reject;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        Message('Reject');
                        ApprovalsMgmt.RejectRecordApprovalRequest(rec.RecordId);
                    end;
                }
                action(delegate)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'Delegate the record change';
                    Caption = 'Delegate';
                    Image = Delegate;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        Message('Delegate');
                        ApprovalsMgmt.DelegateRecordApprovalRequest(rec.RecordId);
                    end;
                }
                action(comment)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'View and Add a comment to the record change';
                    Caption = 'Comment';
                    Image = Comment;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        Message('Comment');
                        ApprovalsMgmt.GetApprovalComment(rec);
                    end;
                }
                action(approvals)
                {
                    ApplicationArea = basic, suite;
                    ToolTip = 'View the approval history';
                    Caption = 'Approvals';
                    Image = Approvals;
                    promoted = true;
                    PromotedCategory = New;
                    trigger OnAction()
                    begin
                        Message('Approvals');
                        ApprovalsMgmt.OpenApprovalEntriesPage(rec.RecordId);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Pagecontrols(Rec);
    end;

    trigger OnAfterGetCurrRecord()

    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        HasApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(rec.RecordId);
        Pagecontrols(Rec);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if rec."Approval Status" <> Rec."Approval Status"::Open then
            Error('Record cannot be modified when Status is %1', Rec."Approval Status");
    end;

    // procedure CheckModificationRestriction(var Rec: Record "Custom Workflow Header"): Boolean
    // var
    //     RestrictionMgmt: Codeunit "Record Restriction Mgt.";
    // begin
    //     Message('Checking modification restriction for Approval Status: %1', Rec."Approval Status");
    //     case Rec."Approval Status" of
    //         Rec."Approval Status"::Pending:
    //             begin
    //                 RestrictionMgmt.CheckRecordHasUsageRestrictions(Rec);
    //                 exit(false);
    //             end;
    //     end;
    //     exit(true);
    // end;

    procedure Pagecontrols(var Rec: Record "Custom Workflow Header")
    begin
        if rec."Approval Status" = Rec."Approval Status"::Open then begin
            CurrPage.Editable := true;
            currpage.Update(false);
        end
        else begin
            CurrPage.Editable := false;
            currpage.Update(false);
        end;
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        OpenApprovalEntriesExistCurrUser: Boolean;
        HasApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
}
