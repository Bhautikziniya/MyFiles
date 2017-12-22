//
//  SettingsTableView.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 10/13/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

class SettingsTableView: AITableView {
    
    var arrSettingOptions = [VCSetting] ()
    
    var didSelectRow:((_ setting:VCSetting, _ row: VCSettingRow)->())?
    
    //var localizationModel: SettingsLocalizationModel!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func commonInit() {
        super.commonInit()
        self.separatorStyle = .singleLine
        self.estimatedRowHeight = 80
        self.sectionHeaderHeight = UITableViewAutomaticDimension
        self.estimatedSectionHeaderHeight = 80.0
        self.sectionFooterHeight = 0.0
        
        self.register(UINib(nibName: String.init(describing: SwitchTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: SwitchTableViewCell.self))
        self.register(UINib(nibName: String.init(describing: ArrowTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: ArrowTableViewCell.self))
        self.register(UINib(nibName: String.init(describing: ArrowWithDetailLabelTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: ArrowWithDetailLabelTableViewCell.self))
        self.register(UINib(nibName: String.init(describing: IconWithOutArrowTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: IconWithOutArrowTableViewCell.self))
        self.register(UINib(nibName: String.init(describing: FromAndToWithArrowTableViewCell.self), bundle: nil), forCellReuseIdentifier: String.init(describing: FromAndToWithArrowTableViewCell.self))
        self.updateColors()
    }
    
    private func updateColors() {
        //        self.theme_backgroundColor = GlobalPicker.backgroundColor
        //        self.theme_separatorColor = GlobalPicker.cellSeparatorColor
    }
    
    func updateDataSourceAndReloadData() {
        self.setupDataSource()
        self.reloadData()
    }
    
    func setupDataSource() {
        
        arrSettingOptions = []
        
        // Language
        let contentLanguage = VCSettingRow(name: GlobalLocalizationModel.shared.contentlanguageLocalizedStr, accessoryTitle: Vachnamrut.shared.language.langName, type: SettingsRowType.arrowWithTitleType, rowType: .contentLanguage)
        let applicationLanguage = VCSettingRow(name: GlobalLocalizationModel.shared.applicationlanguageLocalizedStr, accessoryTitle: Vachnamrut.shared.applicationLanguage.langName, type: SettingsRowType.arrowWithTitleType, rowType: .applicationLanguage)
        
        let languageSetting = VCSetting(type: SettingsSections.language, childOptions: [contentLanguage,applicationLanguage], name: GlobalLocalizationModel.shared.languageSectionLocalizedStr)
        
        // Audio
        let downloadOnly = VCSettingRow(name: GlobalLocalizationModel.shared.downloadOnlyWifiLocalizedStr, accessoryTitle: nil, type: SettingsRowType.switchType, rowType: .downloadOnlyWifi)
        let playingMethod = VCSettingRow(name: GlobalLocalizationModel.shared.playingMethodLocalizedStr, accessoryTitle: Vachnamrut.shared.playingMethod.localizedTitle, type: SettingsRowType.arrowWithTitleType, rowType: .playingMethod)
        let manageAudioFiles = VCSettingRow(name: GlobalLocalizationModel.shared.manageAudioFileLocalizedStr, type: SettingsRowType.arrowType, rowType: .manageAudioFiles)
        //        let downloadAllTracks = VCSettingRow(name: GlobalLocalizationModel.shared.downloadAllTracksLocalizedStr, type: SettingsRowType.arrowType, rowType: .downloadAllTracks)
        //        let deleteAllTracks = VCSettingRow(name: GlobalLocalizationModel.shared.deleteAllTracksLocalizedStr, accessoryTitle: "435 MB", type: SettingsRowType.arrowWithTitleType, rowType: .deleteAllTracks)
        let autoMarkAsReadWithAutio = VCSettingRow(name: GlobalLocalizationModel.shared.autoMarkAsReadLocalizedStr, accessoryTitle: nil, type: SettingsRowType.switchType, rowType: .autoMarkAsReadWithAudio)
        
        let audioSetting = VCSetting(type: SettingsSections.audio, childOptions: [downloadOnly,playingMethod,manageAudioFiles,autoMarkAsReadWithAutio], name: GlobalLocalizationModel.shared.audioSectionLocalizedStr)
        
        // Reading Plan Section
        
        var aryReadingPlanRows:[VCSettingRow] = []
        
        aryReadingPlanRows.append(VCSettingRow(name: GlobalLocalizationModel.shared.readingTargetTypeSelectionLocalizationStr, accessoryTitle: "\(Vachnamrut.shared.readingTargetType == .Count ? "\(Vachnamrut.shared.noOfDailyVerses!) verses" : Vachnamrut.shared.readingPlanDurationTime!.getDurationString())", type: SettingsRowType.arrowWithTitleType, rowType: .readingPlanTargetType))
        
//        if Vachnamrut.shared.readingTargetType == .Count{
//            aryReadingPlanRows.append(VCSettingRow(name: GlobalLocalizationModel.shared.noOfDailyVersesLocalizedStr, accessoryTitle: "\(Vachnamrut.shared.noOfDailyVerses ?? 1) \(GlobalLocalizationModel.shared.noOfDailyVersesVerseLocalizedStr)", type: SettingsRowType.arrowWithTitleType, rowType: .noOfDailyVerses))
//        }else if Vachnamrut.shared.readingTargetType == .Time{
//            aryReadingPlanRows.append(VCSettingRow(name: GlobalLocalizationModel.shared.readingDurationLabelLocalizedStr, accessoryTitle: "\(Vachnamrut.shared.readingPlanDurationTime!.getDurationString())", detailTitle: nil, icon: nil, type: .arrowWithTitleType, rowType: .readingDuration))
//        }
        
        aryReadingPlanRows.append(VCSettingRow(name: GlobalLocalizationModel.shared.reminderLabelLocalizedStr, accessoryTitle: nil, detailTitle: nil, icon: nil, type: .switchType, rowType: .reminder))
        
        if Vachnamrut.shared.readingPlanReminder == true{
            aryReadingPlanRows.append(VCSettingRow(name: GlobalLocalizationModel.shared.reminderTimeLabelLocalizedStr, accessoryTitle: Vachnamrut.shared.reminderTime.getTime, detailTitle: nil, icon: nil, type: .arrowWithTitleType, rowType: .reminderTime))
        }
        
        let readingPlan = VCSetting(type: SettingsSections.readingPlan, childOptions: aryReadingPlanRows, name: GlobalLocalizationModel.shared.readingPlanSectionLocalizationStr)
        
        // Reader Screen

        let strReaderTitle:String = Vachnamrut.shared.screenTimeOut + " " + GlobalLocalizationModel.shared.readerScreenTimeoutMinuteLocalizedStr
        let autoNightMode = VCSettingRow(name: GlobalLocalizationModel.shared.autoNightModeLabelLocalizedStr, accessoryTitle: nil, detailTitle: nil, icon: nil, type: .switchType, rowType: .autoNightMode)
        
        let fromAndTo = VCSettingRow(name: "", accessoryTitle: nil, detailTitle: nil, icon: nil, fromLabel: "From", toLabel: "To", fromTime: Vachnamrut.shared.autoNightModeStartTime.getTime, toTime: Vachnamrut.shared.autoNightModeEndTime.getTime, type: .fromAndToTimeType, rowType: .fromAndTo)
        
        let readerScreenTimeOut = VCSettingRow(name: GlobalLocalizationModel.shared.readerScreenTimeoutLocalizedStr, accessoryTitle: strReaderTitle, type: SettingsRowType.arrowWithTitleType, rowType: .readerScreenTimeOut)
        
        var rows: [VCSettingRow] = [autoNightMode,readerScreenTimeOut]
        
        if Vachnamrut.shared.autoNightMode {
            rows.insert(fromAndTo, at: 1)
        }
        
        let readerScreenSetting = VCSetting(type: SettingsSections.readerScreen, childOptions: rows, name: GlobalLocalizationModel.shared.readerScreenSectionLocalizedStr)
        
        // Theme
        let selectTheme = VCSettingRow(name: GlobalLocalizationModel.shared.selectThemeLocalizedStr, accessoryTitle: "\(Vachnamrut.shared.currentTheme)", type: SettingsRowType.arrowWithTitleType, rowType: .selectTheme)
        
        let themeSetting = VCSetting(type: SettingsSections.theme, childOptions: [selectTheme], name: GlobalLocalizationModel.shared.themeSectionLocalizedStr)
        
        // User-data
        let backup = VCSettingRow(name: GlobalLocalizationModel.shared.backupLocalizedStr, type: SettingsRowType.arrowType, rowType: .backUP)
        let restore = VCSettingRow(name: GlobalLocalizationModel.shared.restoreLocalizedStr, type: SettingsRowType.arrowType, rowType: .restore)
        
        let userData = VCSetting(type: SettingsSections.userData, childOptions: [backup,restore], name: GlobalLocalizationModel.shared.userDataSectionLocalizedStr)
        
        // App Version info
        
        guard let appInfo = Bundle.main.infoDictionary else {
            return
        }

        let shortVersionString = appInfo["CFBundleShortVersionString"] as! String
        let bundleVersion      = appInfo["CFBundleVersion"] as! String
        
        let version = VCSettingRow(name: "Version", accessoryTitle: "\(shortVersionString)    ", type: SettingsRowType.arrowWithTitleType, rowType: .version)
        let build = VCSettingRow(name: "Build", accessoryTitle: "\(bundleVersion)    ", type: SettingsRowType.arrowWithTitleType, rowType: .build)
        
        let appVersion = VCSetting(type: SettingsSections.appVersion, childOptions: [version,build], name: SettingsSections.appVersion.name)
        
        self.arrSettingOptions.append(languageSetting)
        self.arrSettingOptions.append(readerScreenSetting)
        self.arrSettingOptions.append(audioSetting)
        self.arrSettingOptions.append(readingPlan)
        self.arrSettingOptions.append(themeSetting)
        self.arrSettingOptions.append(userData)
        self.arrSettingOptions.append(appVersion)
    }
    
    /*
     func setupDataSource() {
     
     arrSettingOptions = []
     
     // Auto Night Mode
     
     let autoNightMode = VCSettingRow(name: "Auto Night Mode", type: SettingsRowType.switchType)
     
     let autoNightModeSetting = VCSetting(type: SettingsSections.autoNightMode, childOptions: [autoNightMode])
     
     // Audio
     let downloadOnly = VCSettingRow(name: "Download Only", accessoryTitle: "Wi-Fi", type: SettingsRowType.arrowWithTitleType)
     let PlayingMethod = VCSettingRow(name: "Playing Method", accessoryTitle: "Stream and save", type: SettingsRowType.arrowWithTitleType)
     let downloadAllTracks = VCSettingRow(name: "Download all tracks", type: SettingsRowType.arrowType)
     let deleteAllTracks = VCSettingRow(name: "Delete all tracks", accessoryTitle: "435 MB", type: SettingsRowType.arrowWithTitleType)
     let autoMarkAsReadWithAutio = VCSettingRow(name: "Auto \"Mark as read\" with audio", accessoryTitle: nil, type: SettingsRowType.switchType)
     
     let audioSetting = VCSetting(type: SettingsSections.audio, childOptions: [downloadOnly,PlayingMethod,downloadAllTracks,deleteAllTracks,autoMarkAsReadWithAutio])
     
     // Reading Plan
     
     let noOfDailyVerses = VCSettingRow(name: "No. of daily verses", accessoryTitle: "10 Verses", type: SettingsRowType.arrowWithTitleType)
     let reminder = VCSettingRow(name: "Reminder", type: SettingsRowType.switchType)
     let reminderTime = VCSettingRow(name: "Reminder Time", accessoryTitle: "3 Minutes", type: SettingsRowType.arrowWithTitleType)
     
     let readingPlan = VCSetting(type: SettingsSections.readingPlan, childOptions: [noOfDailyVerses,reminder,reminderTime])
     
     // Rreader Screen
     
     let readerScreenTimeOut = VCSettingRow(name: "Reader screen timeout", accessoryTitle: "3 mins", type: SettingsRowType.arrowWithTitleType)
     
     let readerScreen = VCSetting(type: SettingsSections.readerScreen, childOptions: [readerScreenTimeOut])
     
     // Theme
     
     let selectTheme = VCSettingRow(name: "Select Theme", accessoryTitle: "color", type: SettingsRowType.arrowWithTitleType)
     
     let theme = VCSetting(type: SettingsSections.theme, childOptions: [selectTheme])
     
     // User-data
     
     let backup = VCSettingRow(name: "Back-up", type: SettingsRowType.arrowType)
     let restore = VCSettingRow(name: "Restore", type: SettingsRowType.arrowType)
     let syncVia = VCSettingRow(name: "Sync via", accessoryTitle: "Wi-Fi Only", type: SettingsRowType.arrowWithTitleType)
     let syncNow = VCSettingRow(name: "Sync Now", type: SettingsRowType.arrowType)
     
     let userData = VCSetting(type: SettingsSections.userData, childOptions: [backup,restore,syncVia,syncNow])
     
     // Update
     
     let updateRow = VCSettingRow(name: "Update", detailTitle: "Sync content database with server when new content is available", icon: "t", type: SettingsRowType.arrowWithDetailType)
     
     let update = VCSetting(type: SettingsSections.update, childOptions: [updateRow])
     
     // Reset Application
     
     let resetApplicationRow = VCSettingRow(name: "Reset Application", icon: "t", type: SettingsRowType.iconWithoutArrowType)
     
     let resetApplication = VCSetting(type: SettingsSections.resetApplication, childOptions: [resetApplicationRow])
     
     self.arrSettingOptions.append(autoNightModeSetting)
     self.arrSettingOptions.append(audioSetting)
     self.arrSettingOptions.append(readingPlan)
     self.arrSettingOptions.append(readerScreen)
     self.arrSettingOptions.append(theme)
     self.arrSettingOptions.append(userData)
     self.arrSettingOptions.append(update)
     self.arrSettingOptions.append(resetApplication)
     }
     */
    
    //MARK:- UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrSettingOptions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.backgroundViewType = .none
        
        return self.arrSettingOptions[section].arrChildOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let childOption = self.arrSettingOptions[indexPath.section].arrChildOptions[indexPath.row]
        
        //        setup child
        switch childOption.settingType {
        case .arrowType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: ArrowTableViewCell.self)) as? ArrowTableViewCell else {
                return UITableViewCell()
            }
            //            cell.lblDisclosure.isHidden = true
            cell.updateCell(title: childOption.name, disclosureTitle: childOption.accessoryTitle, rowType: childOption.rowType)
            cell.selectionStyle = .none
            
            return cell
        case .arrowWithTitleType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: ArrowTableViewCell.self)) as? ArrowTableViewCell else {
                return UITableViewCell()
            }
            
            //            cell.lblDisclosure.isHidden = false
            cell.updateCell(title: childOption.name, disclosureTitle: childOption.accessoryTitle, rowType: childOption.rowType)
            cell.selectionStyle = .none
            return cell
        case .switchType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: SwitchTableViewCell.self)) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            
            if childOption.rowType == .downloadOnlyWifi {
                cell.updateCell(title: childOption.name, switchOn: Vachnamrut.shared.downloadOnlyWifi)
            } else if childOption.rowType == .autoMarkAsReadWithAudio {
                cell.updateCell(title: childOption.name, switchOn: Vachnamrut.shared.autoMarkAsRead)
            } else if childOption.rowType == .reminder {
                cell.updateCell(title: childOption.name, switchOn: Vachnamrut.shared.readingPlanReminder)
            } else if childOption.rowType == .autoNightMode {
                cell.updateCell(title: childOption.name, switchOn: Vachnamrut.shared.autoNightMode)
            }
            
            cell.switchValueChangedHandler({ (isOn) in
                if childOption.rowType == .downloadOnlyWifi {
                    Vachnamrut.shared.downloadOnlyWifi = isOn
                } else if childOption.rowType == .autoMarkAsReadWithAudio {
                    Vachnamrut.shared.autoMarkAsRead = isOn
                } else if childOption.rowType == .reminder {
                    Vachnamrut.shared.readingPlanReminder = isOn
                    //self.updateDataSourceAndReloadData()
                    self.setupDataSource()
                    self.reloadSections(IndexSet.init(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
                    /*
                     if isOn {
                        VachnamrutNotification.shared.scheduleNotification(atDate: Vachnamrut.shared.reminderTime)
                    } else {
                        VachnamrutNotification.shared.showAllPendingNotifications()
                        VachnamrutNotification.shared.removeAllPendingNotification()
                        VachnamrutNotification.shared.showAllPendingNotifications()
                    }
                     */
                } else if childOption.rowType == .autoNightMode {
                    Vachnamrut.shared.autoNightMode = isOn
                    
                    // Check For AutoNightMode
                    VCAutoNightModeHelper.checkForNightMode()
                    
                    self.setupDataSource()
                    self.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
                }
            })
            
            cell.selectionStyle = .none
            return cell
        case .arrowWithDetailType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: ArrowWithDetailLabelTableViewCell.self)) as? ArrowWithDetailLabelTableViewCell else {
                return UITableViewCell()
            }
            
            cell.updateCell(title: childOption.name, detailTitle: childOption.detailTitle, iconTitle: childOption.icon)
            cell.selectionStyle = .none
            return cell
            
        case .iconWithoutArrowType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: IconWithOutArrowTableViewCell.self)) as? IconWithOutArrowTableViewCell else {
                return UITableViewCell()
            }
            
            cell.updateCell(icon: childOption.icon, title: childOption.name)
            cell.selectionStyle = .none
            
            return cell
        case .fromAndToTimeType:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: FromAndToWithArrowTableViewCell.self)) as? FromAndToWithArrowTableViewCell else {
                return UITableViewCell()
            }
            
            cell.updateCell(withLabel: childOption.fromLabel, toLabel: childOption.toLabel, fromTime: childOption.fromTime, toTime: childOption.toTime)
            cell.selectionStyle = .none
            
            return cell
        case .none:
            return UITableViewCell()
        case .detailLabelWithOutArrow:
            return UITableViewCell()
        case .titleLabelWithCenterAlign:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected \(indexPath.row)")
        
        let setting = self.arrSettingOptions[indexPath.section]
        let row = self.arrSettingOptions[indexPath.section].arrChildOptions[indexPath.row]
        
        if let validRowSelected = self.didSelectRow {
            validRowSelected(setting, row)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.arrSettingOptions[section].name
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.arrSettingOptions[indexPath.section].arrChildOptions[indexPath.row].rowType == .fromAndTo {
            return Devices.isIpad ? 100 : 70
        } else {
            return Devices.isIpad ? 80 : 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

