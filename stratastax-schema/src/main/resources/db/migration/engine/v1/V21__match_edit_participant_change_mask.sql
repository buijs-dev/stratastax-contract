-- Which result fields a proposed participant change sets. A MatchEdit is applied later than it is
-- proposed, so a field that was left out (keep the current value) must be told apart from a field
-- that was set to NULL (clear the value): only the fields flagged here are written on approval.
ALTER TABLE match_edit_participant_change ADD COLUMN score_set   BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE match_edit_participant_change ADD COLUMN rank_set    BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE match_edit_participant_change ADD COLUMN outcome_set BOOLEAN NOT NULL DEFAULT false;
