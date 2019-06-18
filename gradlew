/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.common;

import android.content.SharedPreferences;
import android.test.AndroidTestCase;
import android.test.suitebuilder.annotation.MediumTest;
import android.test.suitebuilder.annotation.SmallTest;

public class OperationSchedulerTest extends AndroidTestCase {
    /**
     * OperationScheduler subclass which uses an artificial time.
     * Set {@link #timeMillis} to whatever value you like.
     */
    private class TimeTravelScheduler extends OperationScheduler {
        static final long DEFAULT_TIME = 1250146800000L;  // 13-Aug-2009, 12:00:00 am
        public long timeMillis = DEFAULT_TIME;

        @Override
        protected long currentTimeMillis() { return timeMillis; }
        public TimeTravelScheduler() { super(getFreshStorage()); }
    }

    private SharedPreferences getFreshStorage() {
        SharedPreferences sp = getContext().getSharedPreferences("OperationSchedulerTest", 0);
        sp.edit().clear().commit();
        return sp;
    }

    @MediumTest
    public void testScheduler() throws Exception {
        TimeTravelScheduler scheduler = new TimeTravelScheduler();
        OperationScheduler.Options options = new OperationScheduler.Options();
        assertEquals(Long.MAX_VALUE, scheduler.getNextTimeMillis(options));
        assertEquals(0, scheduler.getLastSuccessTimeMillis());
        assertEquals(0, scheduler.getLastAttemptTimeMillis());

        long beforeTrigger = scheduler.timeMillis;
        scheduler.setTriggerTimeMillis(beforeTrigger + 1000000);
        assertEquals(beforeTrigger + 1000000, scheduler.getNextTimeMillis(options));

        // It will schedule for the later of the trigger and the moratorium...
        scheduler.setMoratoriumTimeMillis(beforeTrigger + 500000);
        assertEquals(beforeTrigger + 1000000, scheduler.getNextTimeMillis(options));
        scheduler.setMoratoriumTimeMillis(beforeTrigger + 1500000);
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));

        // Test enable/disable toggle
        scheduler.setEnabledState(false);
        assertEquals(Long.MAX_VALUE, scheduler.getNextTimeMillis(options));
        scheduler.setEnabledState(true);
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));

        // Backoff interval after an error
        long beforeError = (scheduler.timeMillis += 100);
        scheduler.onTransientError();
        assertEquals(0, scheduler.getLastSuccessTimeMillis());
        assertEquals(beforeError, scheduler.getLastAttemptTimeMillis());
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));
        options.backoffFixedMillis = 1000000;
        options.backoffIncrementalMillis = 500000;
        assertEquals(beforeError + 1500000, scheduler.getNextTimeMillis(options));

        // Two errors: backoff interval increases
        beforeError = (scheduler.timeMillis += 100);
        scheduler.onTransientError();
        assertEquals(beforeError, scheduler.getLastAttemptTimeMillis());
        assertEquals(beforeError + 2000000, scheduler.getNextTimeMillis(options));

        // Reset transient error: no backoff interval
        scheduler.resetTransientError();
        assertEquals(0, scheduler.getLastSuccessTimeMillis());
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));
        assertEquals(beforeError, scheduler.getLastAttemptTimeMillis());

        // Permanent error holds true even if transient errors are reset
        // However, we remember that the transient error was reset...
        scheduler.onPermanentError();
        assertEquals(Long.MAX_VALUE, scheduler.getNextTimeMillis(options));
        scheduler.resetTransientError();
        assertEquals(Long.MAX_VALUE, scheduler.getNextTimeMillis(options));
        scheduler.resetPermanentError();
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));

        // Success resets the trigger
        long beforeSuccess = (scheduler.timeMillis += 100);
        scheduler.onSuccess();
        assertEquals(beforeSuccess, scheduler.getLastAttemptTimeMillis());
        assertEquals(beforeSuccess, scheduler.getLastSuccessTimeMillis());
        assertEquals(Long.MAX_VALUE, scheduler.getNextTimeMillis(options));

        // The moratorium is not reset by success!
        scheduler.setTriggerTimeMillis(0);
        assertEquals(beforeTrigger + 1500000, scheduler.getNextTimeMillis(options));
        scheduler.setMoratoriumTimeMillis(0);
        assertEquals(beforeSuccess, scheduler.getNextTimeMillis(options));

        // Periodic interval after success
        options.periodicIntervalMillis = 25