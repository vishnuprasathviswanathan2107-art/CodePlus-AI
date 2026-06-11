import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import deleteUser from '@salesforce/apex/UserProfileController.deleteUser';
import updateUser from '@salesforce/apex/UserProfileController.updateUser';
import getDashboardData from '@salesforce/apex/CodingDashboardController.getDashboardData';
import markProblemSolved from '@salesforce/apex/CodingDashboardController.markProblemSolved';
import getAnalytics from '@salesforce/apex/CodingDashboardController.getAnalytics';
import getLeaderboard from '@salesforce/apex/CodingDashboardController.getLeaderboard';
import getSolvedLeaderboard from '@salesforce/apex/CodingDashboardController.getSolvedLeaderboard';
import createUser from '@salesforce/apex/UserProfileController.createUser';
import ensureDailyProblems from '@salesforce/apex/CodingDashboardController.ensureDailyProblems';

export default class CodingDashboard extends LightningElement {
    users = [];
    leaderboard = [];
    solvedLeaderboard = [];
    leetcodeToday;
    leetcodeTomorrow;
    codechefToday;
    codechefTomorrow;
    completedProblemIds = [];
    motivationQuote;
    selectedUser;
    analytics;
    wiredDashboard;
    leaderboardTab = 'streak';

    showModal = false;
    showEditModal = false;
    showDeleteConfirm = false;
    deleteCandidateId = null;
    editingUserId = null;

    fullName = '';
    email = '';
    leetcode = '';
    codechef = '';
    avatarUrl = '';
    reminderTime = '20:00';
    morningTime = '08:00';
    reminderEnabled = true;
    motivationEmails = true;

    get selectedUserId() {
        return this.selectedUser?.Id || null;
    }

    @wire(getDashboardData, { selectedUserId: '$selectedUserId' })
    wiredData(result) {
        this.wiredDashboard = result;
        const { error, data } = result;

        if (data) {
            this.users = (data.users || []).map((u) => ({ ...u }));
            this.leetcodeToday = data.leetcodeToday;
            this.leetcodeTomorrow = data.leetcodeTomorrow;
            this.codechefToday = data.codechefToday;
            this.codechefTomorrow = data.codechefTomorrow;
            this.completedProblemIds = data.completedProblemIds || [];
            this.motivationQuote = data.motivationQuote;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        ensureDailyProblems()
            .then(() => {
                if (this.wiredDashboard) {
                    return refreshApex(this.wiredDashboard);
                }
                return undefined;
            })
            .catch((error) => console.error(error));
        this.loadAnalytics();
        this.loadLeaderboards();
    }

    get isStreakLeaderboard() {
        return this.leaderboardTab === 'streak';
    }

    get isSolvedLeaderboard() {
        return this.leaderboardTab === 'solved';
    }

    get streakTabClass() {
        return this.leaderboardTab === 'streak' ? 'tab-btn active' : 'tab-btn';
    }

    get solvedTabClass() {
        return this.leaderboardTab === 'solved' ? 'tab-btn active' : 'tab-btn';
    }

    get hasUsers() {
        return (this.users || []).length > 0;
    }

    get userCountLabel() {
        const count = (this.users || []).length;
        if (count === 0) {
            return 'No members yet';
        }
        if (count === 1) {
            return '1 member';
        }
        return `${count} members`;
    }

    get displayUsers() {
        return (this.users || []).map((user) => {
            let mailStatusText = 'Mail: Not sent';
            let mailSent = false;
            if (user.Last_Daily_Email_Sent__c) {
                const sentDate = new Date(user.Last_Daily_Email_Sent__c);
                mailStatusText = `Mail: Sent ${sentDate.toLocaleDateString()} ${sentDate.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}`;
                mailSent = true;
            }
            
            let nextMailTime = 'Not scheduled';
            if (user.Reminder_Enabled__c && user.Reminder_Time__c) {
                const parts = String(user.Reminder_Time__c).split(':');
                if (parts.length >= 2) {
                    const h = parseInt(parts[0], 10);
                    const m = parts[1];
                    const ampm = h >= 12 ? 'PM' : 'AM';
                    const h12 = h % 12 || 12;
                    nextMailTime = `${h12}:${m} ${ampm}`;
                }
            }

            return {
                ...user,
                initials: this.getInitials(user.Full_Name__c),
                cardClass: this.selectedUser?.Id === user.Id ? 'user-card is-selected' : 'user-card',
                mailStatusText,
                mailSent,
                nextMailTime
            };
        });
    }

    getInitials(name) {
        if (!name) {
            return '?';
        }
        const parts = String(name).trim().split(/\s+/).filter(Boolean);
        if (parts.length === 0) {
            return '?';
        }
        if (parts.length === 1) {
            return parts[0].slice(0, 2).toUpperCase();
        }
        return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }

    get activeLeaderboard() {
        return this.isStreakLeaderboard ? this.leaderboard : this.solvedLeaderboard;
    }

    get leetcodeTodayCompleted() {
        return this.isProblemCompleted(this.leetcodeToday?.Id);
    }

    get codechefTodayCompleted() {
        return this.isProblemCompleted(this.codechefToday?.Id);
    }

    get leetcodeTodayDifficultyClass() {
        return this.difficultyClassFor(this.leetcodeToday);
    }

    get leetcodeTomorrowDifficultyClass() {
        return this.difficultyClassFor(this.leetcodeTomorrow);
    }

    get codechefTodayDifficultyClass() {
        return this.difficultyClassFor(this.codechefToday);
    }

    get codechefTomorrowDifficultyClass() {
        return this.difficultyClassFor(this.codechefTomorrow);
    }

    isProblemCompleted(problemId) {
        if (!problemId) {
            return false;
        }
        return (this.completedProblemIds || []).includes(problemId);
    }

    difficultyClassFor(problem) {
        const level = problem?.Difficulty__c;
        if (level === 'Easy') return 'difficulty easy';
        if (level === 'Hard') return 'difficulty hard';
        return 'difficulty';
    }

    showStreakBoard() {
        this.leaderboardTab = 'streak';
    }

    showSolvedBoard() {
        this.leaderboardTab = 'solved';
    }

    loadAnalytics() {
        getAnalytics()
            .then((result) => {
                this.analytics = result;
            })
            .catch((error) => console.error(error));
    }

    loadLeaderboards() {
        getLeaderboard()
            .then((result) => {
                const sorted = (result || []).slice().sort(
                    (a, b) => (b.Current_Streak__c || 0) - (a.Current_Streak__c || 0)
                );
                this.leaderboard = sorted.map((u, i) => ({ ...u, _rank: i + 1 }));
            })
            .catch((error) => console.error(error));

        getSolvedLeaderboard()
            .then((result) => {
                this.solvedLeaderboard = (result || []).map((u, i) => ({ ...u, _rank: i + 1 }));
            })
            .catch((error) => console.error(error));
    }

    refreshAll() {
        return Promise.all([
            refreshApex(this.wiredDashboard),
            this.loadAnalytics(),
            this.loadLeaderboards()
        ]);
    }

    selectUser(event) {
        const userId = event.currentTarget.dataset.id;
        this.selectedUser = this.users.find((user) => user.Id === userId);
        this.users = [...this.users];
    }

    openModal() {
        this.resetForm();
        this.showModal = true;
    }

    openEditModal() {
        if (!this.selectedUser) {
            return;
        }
        this.editingUserId = this.selectedUser.Id;
        this.fullName = this.selectedUser.Full_Name__c || '';
        this.email = this.selectedUser.Email__c || '';
        this.leetcode = this.selectedUser.LeetCode_Username__c || '';
        this.codechef = this.selectedUser.CodeChef_Username__c || '';
        this.avatarUrl = this.selectedUser.Avatar_URL__c || '';
        this.reminderEnabled = this.selectedUser.Reminder_Enabled__c !== false;
        this.motivationEmails = this.selectedUser.Motivation_Emails__c !== false;
        this.reminderTime = this.formatTimeForInput(this.selectedUser.Reminder_Time__c, '20:00');
        this.morningTime = this.formatTimeForInput(this.selectedUser.Morning_Summary_Time__c, '08:00');
        this.showEditModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.showEditModal = false;
        this.resetForm();
    }

    resetForm() {
        this.editingUserId = null;
        this.fullName = '';
        this.email = '';
        this.leetcode = '';
        this.codechef = '';
        this.avatarUrl = '';
        this.reminderTime = '20:00';
        this.morningTime = '08:00';
        this.reminderEnabled = true;
        this.motivationEmails = true;
    }

    formatTimeForInput(timeValue, fallback) {
        if (!timeValue) {
            return fallback;
        }
        const parts = String(timeValue).split(':');
        if (parts.length < 2) {
            return fallback;
        }
        return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
    }

    handleDelete(event) {
        event.stopPropagation();
        this.deleteCandidateId = event.currentTarget.dataset.id;
        this.showDeleteConfirm = true;
    }

    confirmDelete() {
        const userId = this.deleteCandidateId;
        if (!userId) {
            return;
        }

        deleteUser({ userId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'User Deleted',
                        message: 'User removed from CodePulse AI',
                        variant: 'success'
                    })
                );
                this.showDeleteConfirm = false;
                this.deleteCandidateId = null;
                if (this.selectedUser?.Id === userId) {
                    this.selectedUser = null;
                }
                return this.refreshAll();
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error deleting user',
                        variant: 'error'
                    })
                );
                this.showDeleteConfirm = false;
                this.deleteCandidateId = null;
            });
    }

    cancelDelete() {
        this.showDeleteConfirm = false;
        this.deleteCandidateId = null;
    }

    handleName(event) { this.fullName = event.target.value; }
    handleEmail(event) { this.email = event.target.value; }
    handleLeetcode(event) { this.leetcode = event.target.value; }
    handleCodechef(event) { this.codechef = event.target.value; }
    handleAvatar(event) { this.avatarUrl = event.target.value; }
    handleReminderTime(event) { this.reminderTime = event.target.value; }
    handleMorningTime(event) { this.morningTime = event.target.value; }
    handleReminderEnabled(event) { this.reminderEnabled = event.target.checked; }
    handleMotivation(event) { this.motivationEmails = event.target.checked; }

    saveUser() {
        if (!this.fullName?.trim() || !this.email?.trim()) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required Fields',
                    message: 'Please enter your name and email',
                    variant: 'warning'
                })
            );
            return;
        }

        createUser({
            fullName: this.fullName,
            email: this.email,
            leetCodeUsername: this.leetcode,
            codeChefUsername: this.codechef,
            avatarUrl: this.avatarUrl,
            reminderTime: this.reminderTime,
            morningSummaryTime: this.morningTime,
            reminderEnabled: this.reminderEnabled,
            motivationEmails: this.motivationEmails
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'User Created',
                        message: 'Welcome to CodePulse AI',
                        variant: 'success'
                    })
                );
                this.closeModal();
                return ensureDailyProblems()
                    .then(() => this.refreshAll())
                    .catch((refreshError) => {
                        console.error(refreshError);
                    });
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error?.body?.message || 'Error creating user',
                        variant: 'error'
                    })
                );
            });
    }

    saveEdit() {
        const editedUserId = this.editingUserId;

        updateUser({
            userId: editedUserId,
            fullName: this.fullName,
            email: this.email,
            leetCodeUsername: this.leetcode,
            codeChefUsername: this.codechef,
            avatarUrl: this.avatarUrl,
            reminderTime: this.reminderTime,
            morningSummaryTime: this.morningTime,
            reminderEnabled: this.reminderEnabled,
            motivationEmails: this.motivationEmails
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Profile Updated',
                        message: 'Your settings were saved',
                        variant: 'success'
                    })
                );
                this.closeModal();
                return this.refreshAll().then(() => {
                    if (editedUserId) {
                        this.selectedUser =
                            this.users.find((u) => u.Id === editedUserId) || this.selectedUser;
                    }
                });
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error?.body?.message || 'Error updating user',
                        variant: 'error'
                    })
                );
            });
    }

    handleSolveClick(event) {
        const problemId = event.currentTarget.dataset.id;
        this.handleSolve(problemId);
    }

    handleSolve(problemId) {
        if (!problemId || !this.selectedUser) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Select user',
                    message: 'Select a user from the sidebar first',
                    variant: 'warning'
                })
            );
            return;
        }

        markProblemSolved({
            problemId,
            userId: this.selectedUser.Id
        })
            .then((result) => {
                let message;
                if (result?.alreadySolvedToday) {
                    message = 'Already marked complete for this problem.';
                } else if (result?.streakUpdated) {
                    message = `Complete! Streak: ${result?.streak} day(s). Check your email for confirmation.`;
                } else {
                    message = 'Marked complete.';
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Problem complete',
                        message,
                        variant: 'success'
                    })
                );
                return this.refreshAll();
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error?.body?.message || 'Could not mark complete',
                        variant: 'error'
                    })
                );
            });
    }
}
