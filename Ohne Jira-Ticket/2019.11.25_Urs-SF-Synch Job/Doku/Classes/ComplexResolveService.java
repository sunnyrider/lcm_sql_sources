package ch.local.crm.server.complex;

import static org.eclipse.scout.ql.QL.*;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.scout.commons.StringUtility;
import org.eclipse.scout.commons.TypeCastUtility;
import org.eclipse.scout.commons.logger.IScoutLogger;
import org.eclipse.scout.commons.logger.ScoutLogManager;
import org.eclipse.scout.ql.QL;
import org.eclipse.scout.rt.persistence.HQuery;
import org.eclipse.scout.service.AbstractService;

import ch.local.crm.server.legalentity.BsiXLegalEntityView_aliased;
import ch.local.crm.server.persistence.LcmBinds;
import ch.local.crm.server.persistence.orm.BsiXAddress;
import ch.local.crm.server.persistence.orm.BsiXCompany_aliased;
import ch.local.crm.server.persistence.orm.BsiXComplexHistory_aliased;
import ch.local.crm.server.persistence.orm.BsiXExtJoinJoin_aliased;
import ch.local.crm.server.persistence.orm.BsiXExtJoin_aliased;
import ch.local.crm.shared.complex.AddressNoResolvingException;
import ch.local.crm.shared.complex.ComplexNoResolvingException;
import ch.local.crm.shared.complex.IComplexResolveService;
import ch.local.crm.shared.external.LcmComplexChangeCodeType;

import com.bsiag.crm.server.core.persistence.CoreBinds;
import com.bsiag.crm.server.core.persistence.JPA;
import com.bsiag.crm.shared.core.address.AddressKey;
import com.bsiag.crm.shared.core.company.CompanyKey;
import com.bsiag.crm.shared.core.configuration.code.Uid;
import com.bsiag.crm.shared.core.legalentity.ILegalEntityKey;
import com.bsiag.crm.shared.core.person.PersonKey;

/**
 * Complex No Resolving service If entity is inactive complexNo / key resolving
 * should throw a resolving exception
 */
public class ComplexResolveService extends AbstractService implements IComplexResolveService {
	private static final IScoutLogger LOG = ScoutLogManager.getLogger(ComplexResolveService.class);

	@Override
	public String resolveComplexNo(ILegalEntityKey key) throws ComplexNoResolvingException {
		LOG.error("(INFO - NO ERROR) START: Resolving COMPLEX_NO for " + key.toString());
		BsiXLegalEntityView_aliased le = new BsiXLegalEntityView_aliased("le");
		LcmBinds binds = new LcmBinds();

		String result = "";
		final CharSequence qrySeq = QL.select(le.complexNo).from(le.TABLE).where(eq(le.key, binds.setDomainKey(key)));
		final HQuery<String> query = JPA.createSuperUserSQL92Query(String.class, qrySeq);
		LOG.error("(INFO - NO ERROR): Query: " + query.getQueryString());

		try {
			final String complexNo = binds.applyQueryParameters(query).uniqueResult();

			if (complexNo == null) {
				LOG.error("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString());
				throw new ComplexNoResolvingException("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString());
			}
			result = complexNo;
		} catch (ComplexNoResolvingException ex) {
			LOG.error("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString() + "\n" + ex.getMessage());
			throw new ComplexNoResolvingException("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString() + "\n" + ex.getMessage());
		} catch (Exception ex) {
			LOG.error("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString() + "\n" + ex.getMessage());
			throw new ComplexNoResolvingException("Could not resolve COMPLEX_NO for " + key.toString() + ", Query: " + query.getQueryString() + "\n" + ex.getMessage());
		}

		return result;
	}

	protected ILegalEntityKey resolveLegalEntityKey(String complexNo) throws ComplexNoResolvingException {
		BsiXLegalEntityView_aliased le = new BsiXLegalEntityView_aliased("le");
		LcmBinds binds = new LcmBinds();
		HQuery<ILegalEntityKey> query = JPA.createSuperUserSQL92Query(ILegalEntityKey.class,
				QL.select(le.key).from(le.TABLE).where(eq(le.complexNo, binds.setString(complexNo)), eq(le.active, binds.setBoolean(true))));
		ILegalEntityKey key = binds.applyQueryParameters(query).uniqueResult();
		if (key == null) {
			throw new ComplexNoResolvingException(complexNo);
		}
		return key;
	}

	protected ILegalEntityKey resolveLegalEntityViaHistory(String complexNo) throws ComplexNoResolvingException {
		ILegalEntityKey key = resolveLegalEntityViaHistory(complexNo, new HashSet<String>());
		if (key == null) {
			throw new ComplexNoResolvingException(complexNo);
		}
		return key;
	}

	protected ILegalEntityKey resolveLegalEntityViaHistory(String complexNo, Set<String> loopDetection) {
		ILegalEntityKey key = null;
		try {
			key = resolveLegalEntityKey(complexNo);
		} catch (ComplexNoResolvingException e) {
			//nop
		}
		if (key == null && !loopDetection.contains(complexNo)) {
			loopDetection.add(complexNo);
			// try to find a history entry for this complexNo

			LcmBinds binds = new LcmBinds();
			BsiXComplexHistory_aliased ch = new BsiXComplexHistory_aliased("ch");
			String followupComplexNo = binds.applyQueryParameters(
					JPA.createSuperUserSQL92Query(
							String.class,
							QL.selectDistinct(ch.newComplexNo)
									.from(ch.TABLE)
									.where(not(in(ch.newComplexNo, binds.setList(loopDetection, String.class))), ne(ch.oldComplexNo, ch.newComplexNo),
											eq(ch.oldComplexNo, binds.setString(complexNo)), isNotNull(ch.newComplexNo)))).uniqueResult();

			if (StringUtility.hasText(followupComplexNo)) {
				key = resolveLegalEntityViaHistory(followupComplexNo, loopDetection);
			}
		}

		return key;
	}

	@Override
	public ILegalEntityKey resolveKey(String complexNo) throws ComplexNoResolvingException {
		return resolveLegalEntityKey(complexNo);
	}

	@Override
	public String resolveComplexNo(String externalNo, Uid sourceSystemUid) throws ComplexNoResolvingException {
		BsiXExtJoinJoin_aliased ejj = new BsiXExtJoinJoin_aliased("ejj");
		BsiXExtJoin_aliased ej = new BsiXExtJoin_aliased("ej");
		BsiXCompany_aliased c = new BsiXCompany_aliased("c");
		LcmBinds binds = new LcmBinds();
		String complexNo = binds.applyQueryParameters(
				JPA.createSuperUserSQL92Query(
						String.class,
						QL.select(c.complexNo)
								.from(c.TABLE)
								.join(ejj.TABLE, eq(c.key, ejj.joinNr))
								.join(ej.TABLE, eq(ejj.extJoinKey, ej.key))
								.where(eq(ej.joinNo, binds.setString(externalNo)), eq(ej.interfaceUid, binds.setUid(sourceSystemUid)),
										eq(c.active, binds.setBoolean(true))))).uniqueResult();
		if (complexNo == null) {
			throw new ComplexNoResolvingException("No complex_no found for BSI_X_EXT_JOIN.JOIN_NO = " + externalNo);
		}
		return complexNo;
	}

	@Override
	public CompanyKey resolveCompanyKey(String complexNo) throws ComplexNoResolvingException {
		return resolve(complexNo, CompanyKey.class);
	}

	@Override
	public PersonKey resolvePersonKey(String complexNo) throws ComplexNoResolvingException {
		return resolve(complexNo, PersonKey.class);
	}

	private <T> T resolve(String complexNo, Class<T> clazz) throws ComplexNoResolvingException {
		ILegalEntityKey legalEntityKey = resolveLegalEntityKey(complexNo);
		T key;
		try {
			key = TypeCastUtility.castValue(legalEntityKey, clazz);
		} catch (IllegalArgumentException e) {
			throw new ComplexNoResolvingException(complexNo);
		}
		if (key != null) {
			return key;
		}
		throw new ComplexNoResolvingException(complexNo);
	}

	@Override
	public AddressKey resolveAddressKey(String addressNo) throws AddressNoResolvingException {
		BsiXAddress address = BsiXAddress.findByAddressNo(addressNo);
		if (address == null) {
			throw new AddressNoResolvingException(addressNo);
		}

		return address.getKey();
	}

	@Override
	public ILegalEntityKey resolveKeyViaHistory(String complexNo) throws ComplexNoResolvingException {
		return resolveLegalEntityViaHistory(complexNo);
	}

	@Override
	public String[] loadMergedNos(String complexNo) throws ComplexNoResolvingException {
		LOG.debug("loadMergedNos for complexNo " + complexNo);
		CoreBinds binds = new CoreBinds();
		List<?> list = binds.applyQueryParameters(
				JPA.createNativeSQLQuery("" + "SELECT DISTINCT OLD_COMPLEX_NO " + "FROM   BSI_X_COMPLEX_HISTORY " + "START WITH NEW_COMPLEX_NO = "
						+ binds.setString(complexNo) + " AND CHANGE_TYPE_UID = " + binds.setUid(LcmComplexChangeCodeType.MergedCode.UID) + " "
						+ "CONNECT BY PRIOR OLD_COMPLEX_NO = NEW_COMPLEX_NO AND CHANGE_TYPE_UID = " + binds.setUid(LcmComplexChangeCodeType.MergedCode.UID)
						+ " ")).list();
		return list.toArray(new String[list.size()]);
	}
}
