/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 *
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.emtfrontend;

import java.text.SimpleDateFormat;

public class Constants {

	// would be nice to get it from the maven build
	public static final String EMT_VERSION = "0.5-SNAPSHOT";

	// for log file and properties
	public static String RUNTIME_DIR = "/home/hc-admin";
//	public static String RUNTIME_DIR = "/Users/xian/projects/pih-rwanda/test";
	
	public static String INSTALL_DIR = "/home/hc-admin/EmrMonitoringTool";
	
	public static SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd-HHmmss");
	public static SimpleDateFormat df = new SimpleDateFormat("dd MMM yyyy");
	public static SimpleDateFormat shortDf = new SimpleDateFormat("yyyyMMdd");

	public static int heartbeatCronjobIntervallInMinutes = 15;
	public static int firstHeartbeatCronjobStartsAtMinute = 1;
	public static int openmrsHeartbeatCronjobIntervallInMinutes = 15;
	public static int firstOpenmrsHeartbeatCronjobStartsAtMinute = 2;
}
