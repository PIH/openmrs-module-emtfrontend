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

import java.text.ParseException;
import java.util.Date;
import java.util.StringTokenizer;

public class Heartbeat implements Heartbeatable {
	private Date date = null;
	public int numberProcessors = -1;
	public double loadAverage1Min = -1;
	public double loadAverage5Min = -1;
	public double loadAverage15Min = -1;
	public int totalMemory = -1;
	public int freeMemory = -1;

	public Heartbeat(String timestamp, StringTokenizer st)
			throws ParseException {
		date = Constants.sdf.parse(timestamp);
		try {
			if (st.hasMoreTokens())
				loadAverage1Min = Double.parseDouble(st.nextToken());
			if (st.hasMoreTokens())
				loadAverage5Min = Double.parseDouble(st.nextToken());
			if (st.hasMoreTokens())
				loadAverage15Min = Double.parseDouble(st.nextToken());
			if (st.hasMoreTokens())
				numberProcessors = Integer.parseInt(st.nextToken());
			if (st.hasMoreTokens())
				totalMemory = Integer.parseInt(st.nextToken());
			if (st.hasMoreTokens())
				freeMemory = Integer.parseInt(st.nextToken());
		} catch (NumberFormatException p) {
			p.printStackTrace();
		}
	}

	public Date date() {
		return this.date;
	}
}
