package teckubelicense

import (
	"errors"
	"time"

	"github.com/coreos-inc/tectonic-licensing/license"
)

const (
	// From tectonic-enterprise plans, have this entitlement. This results in
	// no enforcement
	tectonicEnterpriseSoftwareEntitlementName = "software.tectonic"
	// new Tectonic plans have this entitlement, and require enforcement
	tectonicSoftwareEntitlementName = "software.tectonic-2016-12"
	// These are the individual entitlements which the user gets and are what
	// we look for when determining the values to enforce
	tectonicFreeNodeCountEntitlementName = "software.tectonic-2016-12.free-node-count"
	tectonicVCPUPairEntitlementName      = "software.tectonic-2016-12.vcpu-pair"
	tectonicSocketPairEntitlementName    = "software.tectonic-2016-12.socket-pair"

	// The "disable-enforcement" entitlement is used as a way to generate licenses which
	// aren't enforced.
	//
	// We don't generate licenses with this value today, but gives us a way to skip
	// enforcement in old components that potentially might not be compatible with a
	// future license schema.
	tectonicDisableEnforcementEntitlement = "software.tectonic-2016-12.disable-enforcement"
)

var (
	defaultGracePeriodDays = 30
	// ErrGracePeriodExpired is returned when the grace period is over
	ErrGracePeriodExpired = errors.New("your Tectonic subscriptions are expired")
	// ErrNoActiveSubscriptions is returned when the license has no active
	// Tectonic subscriptions
	ErrNoActiveSubscriptions = errors.New("license does not contain any active Tectonic subscriptions")

	// ErrNoEnforcement is returned when trying to get enforcement details
	// when enforcement should be bypassed
	ErrNoEnforcement = errors.New("no license details to enforce")
	// ErrCannotEnforce is returned when it's determined the license needs to
	// be enforced, but no enforcements are found. This is a violation of
	// internal constraints, and should not happen. However, panicking is not
	// a choice, and we should fall closed and restrict access.
	ErrCannotEnforce = errors.New("no entitlements found, but enforcement required")
)

// LicenseDetails is an interface for retrieving information related to
// enforcing and displaying entitlements from a license.
type LicenseDetails interface {
	SubscriptionEnd() time.Time
	// GracePeriodEnd  should be checked before performing any enforcement
	GracePeriodEnd() time.Time

	// BypassEnforcement must be checked prior to calling EnforcementDetails.
	// BypassEnforcement will return false if you should be checking
	// enforcements, if it returns true, you should not call EnforcementDetails
	// ErrNoEnforcement will be returned from EnforcementDetails if you do.
	// This only expected to return true if a subscriptions entitlements
	// includes "software.tectonic", which is for older subscriptions that were
	// sold prior to Tectonic enforcing any entitlements.
	BypassEnforcement() bool
	EnforcementDetails(time.Time) (EnforcementDetails, error)
}

type EnforcementDetails interface {
	LimitNodeSize() bool
	// These methods mutally exclusive. Only one of
	// NodeCountEnforcement(), VCPUsCountEnforcement(),
	// SocketsCountEnforcement() will return non-nil.
	NodeCountEnforcement() *int64
	VCPUsCountEnforcement() *int64
	SocketsCountEnforcement() *int64
}

type licenseDetails struct {
	subscriptionEnd time.Time
	gracePeriodEnd  time.Time

	activeSubscriptionCount int
	bypassEnforcement       bool
	enforcementDetails      *enforcementDetails
}

// GetLicenseDetails extracts the information necessary to check if a user
// is in compliance with their license. It takes a license, and a reference
// time to determine which subscriptions in the license are currently active.
func GetLicenseDetails(lic *license.License, now time.Time) LicenseDetails {
	var (
		nodes, vcpus, sockets              int64
		softwareCount, legacySoftwareCount int
		bypassEnforcement                  bool
	)
	subEnd := lic.ExpirationDate
	for _, sub := range lic.Subscriptions {
		// Skip the subs that haven't started yet
		if sub.Inactive(now) {
			continue
		}
		expired := sub.Expired(now)

		var checkSubEnd bool
		for entitlement, value := range sub.Entitlements {
			switch entitlement {
			case tectonicEnterpriseSoftwareEntitlementName:
				checkSubEnd = true
				if !expired {
					legacySoftwareCount++
				}
			case tectonicSoftwareEntitlementName:
				checkSubEnd = true
				if !expired {
					softwareCount++
				}
			case tectonicFreeNodeCountEntitlementName:
				if !expired && value > nodes {
					nodes = value
				}
			case tectonicVCPUPairEntitlementName:
				if !expired {
					vcpus += 2 * value // mult by 2 to go from number of pairs to number of vcpus
				}
			case tectonicSocketPairEntitlementName:
				if !expired {
					sockets += 2 * value // mult by 2 to go from number of pairs to number of sockets
				}
			case tectonicDisableEnforcementEntitlement:
				if !expired {
					bypassEnforcement = true
				}
			}
		}
		if checkSubEnd && sub.ServiceEnd.After(subEnd) {
			subEnd = sub.ServiceEnd
		}
	}
	gracePeriodEnd := subEnd.AddDate(0, 0, defaultGracePeriodDays)

	if !bypassEnforcement {
		bypassEnforcement = legacySoftwareCount > 0
	}
	activeSubscriptionCount := softwareCount + legacySoftwareCount

	enforce := new(enforcementDetails)

	// Prefer sockets and vcpus over nodes, but prefer sockets over vcpus
	if sockets > 0 {
		enforce.sockets = &sockets
	} else if vcpus > 0 {
		enforce.vcpus = &vcpus
	} else if nodes > 0 {
		enforce.nodes = &nodes
	}

	return &licenseDetails{
		subscriptionEnd:         subEnd,
		gracePeriodEnd:          gracePeriodEnd,
		bypassEnforcement:       bypassEnforcement,
		enforcementDetails:      enforce,
		activeSubscriptionCount: activeSubscriptionCount,
	}
}

func (details *licenseDetails) SubscriptionEnd() time.Time {
	return details.subscriptionEnd
}

func (details *licenseDetails) GracePeriodEnd() time.Time {
	return details.gracePeriodEnd
}

func (details *licenseDetails) BypassEnforcement() bool {
	return details.bypassEnforcement
}

func (details *licenseDetails) EnforcementDetails(now time.Time) (EnforcementDetails, error) {
	if details.activeSubscriptionCount == 0 {
		return nil, ErrNoActiveSubscriptions
	}
	if details.bypassEnforcement {
		return nil, ErrNoEnforcement
	}
	if now.After(details.gracePeriodEnd) {
		return nil, ErrGracePeriodExpired
	}
	return details.enforcementDetails, nil
}

type enforcementDetails struct {
	nodes   *int64
	vcpus   *int64
	sockets *int64
}

func (details *enforcementDetails) LimitNodeSize() bool {
	return details.nodes != nil
}

func (details *enforcementDetails) NodeCountEnforcement() *int64 {
	return details.nodes
}

func (details *enforcementDetails) VCPUsCountEnforcement() *int64 {
	return details.vcpus
}

func (details *enforcementDetails) SocketsCountEnforcement() *int64 {
	return details.sockets
}

// GetEnforcementKindAndCount is a utility function which handles getting
// one of the mutually exclusive entitlements from LicenseDetails. It returns
// a string representation of the entitlement which needs enforcing, and an
// integer value to use for enforcement limits. If the final return value is
// true, enforcement is necessary, otherwise enforcement is not necessary. It
// is considered an error if ("", 0, true) is returned.
func GetEnforcementKindAndCount(details LicenseDetails, now time.Time) (string, int64, bool, error) {
	bypass := details.BypassEnforcement()
	if bypass {
		return "", 0, false, nil
	}

	enforcement, err := details.EnforcementDetails(now)
	if err != nil {
		return "", 0, false, err
	}

	nodeCount := enforcement.NodeCountEnforcement()
	vcpuCount := enforcement.VCPUsCountEnforcement()
	socketCount := enforcement.SocketsCountEnforcement()

	if socketCount != nil {
		return "sockets", *socketCount, true, nil
	} else if vcpuCount != nil {
		return "vCPUs", *vcpuCount, true, nil
	} else if nodeCount != nil {
		return "nodes", *nodeCount, true, nil
	}

	return "", 0, true, ErrCannotEnforce
}
