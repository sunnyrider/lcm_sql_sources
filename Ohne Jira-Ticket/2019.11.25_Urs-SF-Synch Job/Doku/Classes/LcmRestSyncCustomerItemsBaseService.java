package ch.local.crm.server.interfaces.restsync.customer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.eclipse.scout.commons.exception.ProcessingException;
import org.eclipse.scout.commons.logger.IScoutLogger;
import org.eclipse.scout.commons.logger.ScoutLogManager;
import org.eclipse.scout.service.AbstractService;
import org.eclipse.scout.service.SERVICES;

import ch.local.crm.server.complex.ComplexResolveService;
import ch.local.crm.server.core.address.ILcmAddressBaseService;
import ch.local.crm.server.interfaces.restsync.LcmCustomerSyncItem;
import ch.local.crm.server.persistence.orm.BsiXExtJoin;
import ch.local.crm.shared.address.LcmElectronicAddressBean;
import ch.local.crm.shared.address.LcmPhysicalAddressBean;
import ch.local.crm.shared.company.ILcmCompanyDomain;
import ch.local.crm.shared.complex.ComplexNoResolvingException;
import ch.local.crm.shared.complex.IComplexResolveService;
import ch.local.crm.shared.configuration.code.AddressTypeCodeType;
import ch.local.crm.shared.external.company.LcmExtCompanyKey;
import ch.local.crm.shared.external.join.ILcmExtJoinKey;
import ch.local.crm.shared.interfaces.common.code.LcmInterfaceCodeType;

import com.bsiag.crm.server.core.company.BsiCompany;
import com.bsiag.crm.server.core.company.relation.BsiCompanyCompany;
import com.bsiag.crm.server.core.persistence.JPA;
import com.bsiag.crm.server.core.scheduler.ISchedulerBaseService;
import com.bsiag.crm.shared.core.address.AddressChannelCodeType;
import com.bsiag.crm.shared.core.common.CoreUtility;
import com.bsiag.crm.shared.core.company.CompanyKey;
import com.bsiag.crm.shared.core.configuration.code.LanguageCode;
import com.bsiag.crm.shared.core.configuration.code.Uid;
import com.bsiag.crm.shared.core.domain.DomainRegistry;
import com.bsiag.crm.shared.core.legalentity.ILegalEntityKey;

public class LcmRestSyncCustomerItemsBaseService extends AbstractService implements ILcmRestSyncCustomerItemsBaseService {

	private static final IScoutLogger LOG = ScoutLogManager.getLogger(ComplexResolveService.class);

	@Override
	public List<CustomerItem> loadCustomerItems(Collection<LcmCustomerSyncItem> syncItems) throws ProcessingException {
		if (syncItems == null || syncItems.isEmpty()) {
			return Collections.emptyList();
		}
		List<CustomerItem> customers = new ArrayList<CustomerItem>();

		for (LcmCustomerSyncItem syncItem : syncItems) {
			try {
				customers.add(loadCustomerItem(syncItem));
			} catch (ProcessingException ex) {
				LOG.error("Error in " + syncItem.toString() + "\n" + ex.getMessage());
				throw new ProcessingException("Error in " + syncItem.toString() + "\n" + ex.getMessage());
			} catch (Exception ex) {
				LOG.error("Error in " + syncItem.toString() + "\n" + ex.getMessage());
				throw new ProcessingException("Error in " + syncItem.toString() + "\n" + ex.getMessage());
			}
		}
		return customers;
	}

	private CustomerItem loadCustomerItem(LcmCustomerSyncItem syncItem) throws ProcessingException {
		CustomerItem customerItem = new CustomerItem();
		if (isCompany(syncItem)) {
			try {
				SERVICES.getService(ISchedulerBaseService.class).logJobInfoMessage(null, "Try to load LcmCustomerSyncItem  " + syncItem.toString());
				customerItem.setComplexNo(SERVICES.getService(IComplexResolveService.class).resolveComplexNo(syncItem.getCustomerKey()));
				customerItem.setName(getCompanyName(syncItem.getCustomerKey()));
				customerItem.setMergedComplexNoList(getMergedIds(customerItem.getComplexNo()));
				setParentCompanyId(syncItem, customerItem);
				setExternalCustomers(syncItem, customerItem);
			} catch (ProcessingException ex) {
				LOG.error("Error in " + syncItem.toString() + "\n" + ex.getMessage());
				throw new ProcessingException("Error in " + syncItem.toString() + "\n" + ex.getMessage());
			} catch (Exception ex) {
				LOG.error("Error in " + syncItem.toString() + "\n" + ex.getMessage());
				throw new ProcessingException("Error in " + syncItem.toString() + "\n" + ex.getMessage());
			}
		} else {
			throw new ProcessingException("Sync service supports only companies at the moment and not persons " + syncItem.getCustomerKey());
		}
		return customerItem;
	}

	private boolean isCompany(LcmCustomerSyncItem syncItem) {
		if (syncItem.getCustomerKey() instanceof CompanyKey) {
			return true;
		}
		return false;
	}

	@Override
	public ExtCustomerRefItem getExtCustomerRefItem(final ILcmExtJoinKey extJoinKey) throws ProcessingException {
		return getExtCustomerRefItem(JPA.getSuperUser(BsiXExtJoin.class, extJoinKey));
	}

	private ExtCustomerRefItem getExtCustomerRefItem(final BsiXExtJoin extJoin) throws ProcessingException {
		if (extJoin == null) {
			throw new ProcessingException("ExtCustomer not found ");
		}
		final ExtCustomerRefItem extCustomerRef = new ExtCustomerRefItem();
		extCustomerRef.setJoinNo(extJoin.getJoinNo());
		extCustomerRef.setSourceSystemUid(extJoin.getInterfaceUid() == LcmInterfaceCodeType.LtvGelbeSeitenAgSambaCode.AddressCode.UID ? "LTV" : "Unknown");
		return extCustomerRef;
	}

	private void setExternalCustomers(LcmCustomerSyncItem syncItem, CustomerItem customerItem) throws ProcessingException {
		List<ExtCustomerItem> externalCustomerList = new ArrayList<ExtCustomerItem>();
		final ILcmAddressBaseService addressService = SERVICES.getService(ILcmAddressBaseService.class);
		for (ILcmExtJoinKey key : syncItem.getExtJoinKeys()) {
			BsiXExtJoin extJoin = JPA.getSuperUser(BsiXExtJoin.class, key);
			ExtCustomerItem item = new ExtCustomerItem();
			item.setExtCustomerRef(getExtCustomerRefItem(extJoin));
			item.setName(extJoin.getName());
			item.setLocked(extJoin.isLocked());
			item.setActive(extJoin.isActive());
			item.setEvtModified(extJoin.getEvtChanged());
			item.setLanguage(new LanguageCodeItem(String.valueOf(extJoin.getLanguageUid().unwrap()), ((LanguageCode) CoreUtility.getCode(extJoin
					.getLanguageUid())).getShortcut()));

			final Uid addressTypeUid = key instanceof LcmExtCompanyKey ? AddressTypeCodeType.PrimaryAddressCode.UID
					: AddressTypeCodeType.PrivateAddressCode.UID;

			item.setPhysicalAddress(getCompanyPhysicalAddressItem((LcmPhysicalAddressBean) addressService.loadAddressBeanForExternalCustomer(
					syncItem.getCustomerKey(), key, AddressChannelCodeType.AddressCode.UID, addressTypeUid)));

			LcmElectronicAddressBean phone = (LcmElectronicAddressBean) addressService.loadAddressBeanForExternalCustomer(syncItem.getCustomerKey(), key,
					AddressChannelCodeType.PhoneCode.UID, addressTypeUid);
			item.setPhone(phone == null ? null : phone.getChannelValue());

			LcmElectronicAddressBean email = (LcmElectronicAddressBean) addressService.loadAddressBeanForExternalCustomer(syncItem.getCustomerKey(), key,
					AddressChannelCodeType.EmailCode.UID, addressTypeUid);
			item.setEmail(email == null ? null : email.getChannelValue());

			LcmElectronicAddressBean www = (LcmElectronicAddressBean) addressService.loadAddressBeanForExternalCustomer(syncItem.getCustomerKey(), key,
					AddressChannelCodeType.WwwCode.UID, addressTypeUid);
			item.setWww(www == null ? null : www.getChannelValue());

			LcmElectronicAddressBean fax = (LcmElectronicAddressBean) addressService.loadAddressBeanForExternalCustomer(syncItem.getCustomerKey(), key,
					AddressChannelCodeType.FaxCode.UID, addressTypeUid);
			item.setFax(fax == null ? null : fax.getChannelValue());

			LcmElectronicAddressBean mobile = (LcmElectronicAddressBean) addressService.loadAddressBeanForExternalCustomer(syncItem.getCustomerKey(), key,
					AddressChannelCodeType.MobileCode.UID, addressTypeUid);
			item.setMobile(mobile == null ? null : mobile.getChannelValue());

			externalCustomerList.add(item);
		}
		customerItem.setExternalCustomerList(externalCustomerList);
	}

	private PhysicalAddressItem getCompanyPhysicalAddressItem(LcmPhysicalAddressBean addressBean) throws ProcessingException {
		if (addressBean != null) {
			final PhysicalAddressItem item = new PhysicalAddressItem();
			item.setAdditionalLine1(addressBean.getAdditionalLine1());
			item.setStreet(new StreetItem(addressBean.getStreetName(), addressBean.getStreetHouseNo()));
			item.setCity(new CityItem(addressBean.getZipCode(), addressBean.getCity(), addressBean.getState()));
			return item;
		} else {
			return null;
		}
	}

	private String getCompanyName(ILegalEntityKey customerKey) throws ProcessingException {
		BsiCompany company = JPA.getSuperUser(BsiCompany.class, customerKey);
		if (company == null) {
			throw new ProcessingException("Customer not found " + customerKey);
		}
		return DomainRegistry.getDomain(ILcmCompanyDomain.class).getCompanyNameSingleLined(company.getName1(), company.getName2(), company.getName3());
	}

	private List<String> getMergedIds(String complexNo) throws ComplexNoResolvingException {
		String[] nos = SERVICES.getService(IComplexResolveService.class).loadMergedNos(complexNo);
		if (nos != null) {
			return Arrays.asList(nos);
		}
		return null;
	}

	private void setParentCompanyId(LcmCustomerSyncItem syncItem, CustomerItem customerItem) throws ComplexNoResolvingException {
		List<BsiCompanyCompany> companyCompanyList = BsiCompanyCompany.find((CompanyKey) syncItem.getCustomerKey(), null, null);
		if (!companyCompanyList.isEmpty()) {
			//there is max. 1 entry in the list which is the parent company
			CompanyKey parentKey = companyCompanyList.get(0).getGroupCompanyKey();
			customerItem.setParentCompanyId(SERVICES.getService(IComplexResolveService.class).resolveComplexNo(parentKey));
		}
	}

}
